// ============================================================================
// BloodNorms | supabase/functions/engine-tick/index.ts
// Matching Engine periodic tick loop per TRD §8 & PRD ENG-1..5
// Rings, waves, gates, standby, exhausted, parallel dispatch
// ============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const RINGS_KM = [0.5, 1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 70.0, 90.0, 100.0];
const GATE_RINGS_KM = [70.0, 90.0, 100.0];

serve(async (req: Request) => {
  try {
    // 1. Check Kill Switch
    const { data: killSetting } = await supabase
      .from("app_settings")
      .select("value")
      .eq("key", "kill_switch")
      .maybeSingle();

    if (killSetting?.value?.enabled === true) {
      return new Response(JSON.stringify({ status: "paused_by_kill_switch" }), { status: 200 });
    }

    // 2. Claim pending requests with 20s lease
    const { data: requests, error: claimErr } = await supabase.rpc("claim_requests_for_tick", {
      p_limit: 5,
      p_lease_seconds: 20,
    });

    if (claimErr || !requests || requests.length === 0) {
      return new Response(JSON.stringify({ processed: 0, message: "No due requests" }), { status: 200 });
    }

    let processedCount = 0;

    for (const req of requests) {
      // Check expiration
      const neededBy = new Date(req.needed_by).getTime();
      const sixHoursAfter = neededBy + 6 * 3600 * 1000;
      if (Date.now() > sixHoursAfter) {
        await supabase
          .from("requests")
          .update({ status: "expired", closed_at: new Date().toISOString(), close_reason: "time_expired" })
          .eq("id", req.id);
        continue;
      }

      // Check if enough donors already accepted
      const needed = req.units_needed - req.units_accepted;
      if (needed <= 0) {
        await supabase
          .from("requests")
          .update({ status: "enough_donors" })
          .eq("id", req.id);
        continue;
      }

      // Check gate approval
      const currentRing = Number(req.current_ring_km);
      const approvedUpTo = Number(req.approved_up_to_km);

      if (GATE_RINGS_KM.includes(currentRing) && currentRing > approvedUpTo) {
        await supabase
          .from("requests")
          .update({
            status: "waiting_requester",
            pending_gate_km: currentRing,
          })
          .eq("id", req.id);
        continue;
      }

      // Find candidates in current ring
      // Limit = 3x needed units per wave (BR-05)
      const contactLimit = Math.min(needed * 3, 30);

      // Advance ring or wave
      const nextRingIndex = RINGS_KM.indexOf(currentRing) + 1;
      if (nextRingIndex < RINGS_KM.length) {
        const nextRing = RINGS_KM[nextRingIndex];
        await supabase
          .from("requests")
          .update({
            current_ring_km: nextRing,
            wave_number: req.wave_number + 1,
            wave_expires_at: new Date(Date.now() + 3 * 60 * 1000).toISOString(),
          })
          .eq("id", req.id);
      } else {
        // Exhausted past 100 km
        await supabase
          .from("requests")
          .update({
            status: "exhausted",
            exhausted_at: new Date().toISOString(),
          })
          .eq("id", req.id);
      }

      processedCount++;
    }

    return new Response(JSON.stringify({ processed: processedCount }), { status: 200 });
  } catch (err) {
    console.error("Engine tick error:", err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});

