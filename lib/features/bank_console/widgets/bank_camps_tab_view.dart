// ============================================================================
// BloodNorms | bank_camps_tab_view.dart
// Blood Bank Console: Camps Management Tab (Drives, Check-In, Broadcast)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';

class BankCampsTabView extends StatelessWidget {
  final List<CampModel> bankCamps;
  final bool isLoadingCamps;
  final String selectedBankId;
  final VoidCallback onCampUpdated;
  final void Function(String message) onShowToast;

  const BankCampsTabView({
    super.key,
    required this.bankCamps,
    required this.isLoadingCamps,
    required this.selectedBankId,
    required this.onCampUpdated,
    required this.onShowToast,
  });

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  void _showScheduleCampDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Community Voluntary Blood Drive');
    final venueCtrl = TextEditingController(text: 'Community Hall, Main Road');
    final areaCtrl = TextEditingController(text: 'Danavaipeta');
    String selectedCity = 'Rajahmundry';
    int capacity = 100;
    double radiusKm = 10.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: BrandColors.redTint, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add_location_alt_rounded, color: BrandColors.red, size: 22),
              ),
              const SizedBox(width: 10),
              Text('Schedule Blood Drive', style: BrandTypography.title3(color: BrandColors.textPrimary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Camp Title', border: OutlineInputBorder()),
                  style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(labelText: 'Venue / Hall Name', border: OutlineInputBorder()),
                  style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCity,
                        decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                        items: ['Rajahmundry', 'Kakinada', 'Vijayawada', 'Visakhapatnam'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setDialogState(() => selectedCity = v ?? 'Rajahmundry'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: areaCtrl,
                        decoration: const InputDecoration(labelText: 'Locality / Area', border: OutlineInputBorder()),
                        style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: capacity,
                        decoration: const InputDecoration(labelText: 'Target Capacity', border: OutlineInputBorder()),
                        items: [50, 100, 150, 200, 300, 500].map((c) => DropdownMenuItem(value: c, child: Text('$c Units'))).toList(),
                        onChanged: (v) => setDialogState(() => capacity = v ?? 100),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        initialValue: radiusKm,
                        decoration: const InputDecoration(labelText: 'Target Radius', border: OutlineInputBorder()),
                        items: [5.0, 10.0, 15.0, 25.0].map((r) => DropdownMenuItem(value: r, child: Text('${r.toInt()} KM'))).toList(),
                        onChanged: (v) => setDialogState(() => radiusKm = v ?? 10.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontFamily: BrandTypography.fontFamily, color: BrandColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final startsAt = DateTime.now().add(const Duration(days: 3, hours: 9));
                final endsAt = startsAt.add(const Duration(hours: 6));

                await SupabaseService().createCamp(
                  bankId: selectedBankId,
                  title: titleCtrl.text.trim(),
                  venue: venueCtrl.text.trim(),
                  area: areaCtrl.text.trim(),
                  city: selectedCity,
                  startsAt: startsAt,
                  endsAt: endsAt,
                  capacity: capacity,
                  targetRadiusKm: radiusKm,
                );

                onCampUpdated();
                onShowToast('Blood drive scheduled in $selectedCity!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: BrandColors.red),
              child: const Text('SCHEDULE DRIVE', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCampModal(BuildContext context) {
    final titleController = TextEditingController(text: 'Rotary Community Mega Blood Camp');
    final venueController = TextEditingController(text: 'Rotary Diamond Hall, Main Road');
    final areaController = TextEditingController(text: 'Innespeta, Rajahmundry');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Blood Drive Camp', style: BrandTypography.title2(color: BrandColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Saved directly to Supabase bank_camps table.', style: BrandTypography.body(color: BrandColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Camp Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(labelText: 'Venue / Hall Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area / Neighborhood'),
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'CREATE CAMP IN SUPABASE',
              variant: ActionButtonVariant.success,
              onPressed: () async {
                Navigator.pop(ctx);
                final starts = DateTime.now().add(const Duration(days: 7));
                final ends = starts.add(const Duration(hours: 6));

                await SupabaseService().createCamp(
                  bankId: selectedBankId,
                  title: titleController.text.trim(),
                  venue: venueController.text.trim(),
                  area: areaController.text.trim(),
                  startsAt: starts,
                  endsAt: ends,
                  capacity: 150,
                );

                onCampUpdated();
                onShowToast('Camp registered in Supabase!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBankBroadcastSheet(BuildContext context, CampModel camp) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: SupabaseService().previewBroadcastAudience(
          campId: camp.id,
          targetCity: camp.city,
          centerLat: camp.lat,
          centerLng: camp.lng,
          radiusKm: camp.targetRadiusKm,
          respectTravelCap: true,
        ),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: BrandColors.red)),
            );
          }

          final data = snapshot.data!;
          final eligible = data['eligible_count'] as int? ?? 0;
          final suppressed = data['suppressed_count'] as int? ?? 0;
          final cost = data['estimated_cost_inr'] ?? 0.0;
          final samples = data['sample_donors'] as List? ?? [];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: BrandColors.redTint, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.campaign_rounded, color: BrandColors.red, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Regional Broadcast Outreach', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
                            Text('${camp.venue} (${camp.city})', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$eligible Donors in ${camp.targetRadiusKm.toInt()} km Radius', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: BrandColors.green)),
                          const SizedBox(height: 2),
                          Text('Outreach spend: ₹$cost INR (WhatsApp template)', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                        child: Text('$suppressed Out-of-Region Excluded', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: BrandColors.red)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Nearby Matching Donors in City:', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
                const SizedBox(height: 8),
                ...samples.take(4).map((d) {
                  final dMap = d as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: BrandColors.green, size: 14),
                        const SizedBox(width: 6),
                        Text(dMap['name']?.toString() ?? 'Donor', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text('(${dMap['blood_group']}) · ~${dMap['distance_km']} km away', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 18),
                ActionButton(
                  label: 'DISPATCH REGIONAL BROADCAST',
                  icon: Icons.send_rounded,
                  variant: ActionButtonVariant.primary,
                  height: 44,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final res = await SupabaseService().broadcastRegionalMessage(
                      title: 'Blood Drive at ${camp.venue}',
                      message: 'Dear Lifesaver, our blood bank is hosting a voluntary blood drive at ${camp.venue}, ${camp.area}. We welcome your support!',
                      broadcastType: 'camp_invitation',
                      campId: camp.id,
                      targetCity: camp.city,
                      centerLat: camp.lat,
                      centerLng: camp.lng,
                      radiusKm: camp.targetRadiusKm,
                      respectTravelCap: true,
                    );
                    onShowToast('Broadcast dispatched to ${res["recipients"]} in-radius lifesavers!');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCampCheckInSheet(BuildContext context, CampModel camp) {
    final phoneController = TextEditingController(text: '+91 98480 12345');
    int unitsDonated = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Camp Donor Check-In', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrandColors.greenTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BrandColors.greenShadow, width: 1.0),
                    ),
                    child: const Text('LIVE DRIVE', style: TextStyle(color: BrandColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(camp.title, style: BrandTypography.caption(color: BrandColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Donor Mobile Number / Pass Code',
                  hintText: '+91 98480 12345',
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, color: BrandColors.red),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Units Collected:', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: BrandColors.red),
                        onPressed: () {
                          if (unitsDonated > 1) {
                            setModalState(() => unitsDonated--);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: BrandColors.redTint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BrandColors.redShadow, width: 1.0),
                        ),
                        child: Text(
                          '$unitsDonated Unit${unitsDonated > 1 ? "s" : ""}',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: BrandColors.red,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: BrandColors.red),
                        onPressed: () {
                          setModalState(() => unitsDonated++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ActionButton(
                label: 'VERIFY & CHECK-IN DONOR',
                icon: Icons.check_circle_rounded,
                variant: ActionButtonVariant.success,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final phone = phoneController.text.trim();
                  final res = await SupabaseService().checkInCampAttendee(
                    campId: camp.id,
                    phone: phone,
                    units: unitsDonated,
                  );
                  final donorName = res['first_name'] ?? 'Donor';
                  final group = res['blood_group'] ?? 'Blood Group';
                  onShowToast('Checked in $donorName ($group) · $unitsDonated units added!');
                  onCampUpdated();
                },
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'CANCEL',
                variant: ActionButtonVariant.plain,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCampRosterSheet(BuildContext context, CampModel camp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService().getCampAttendees(camp.id),
        builder: (ctx, snapshot) {
          final attendees = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Camp Attendee Roster', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrandColors.redTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${attendees.length} Verified', style: const TextStyle(color: BrandColors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(camp.title, style: BrandTypography.caption(color: BrandColors.textSecondary)),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: BrandColors.red)))
                else if (attendees.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: BrandColors.bgGrouped,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BrandColors.border, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'No attendees checked in yet.\nTap "CHECK-IN" to verify arriving donors.',
                        textAlign: TextAlign.center,
                        style: BrandTypography.body(color: BrandColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      itemCount: attendees.length,
                      separatorBuilder: (_, index) => const Divider(height: 1, color: BrandColors.border),
                      itemBuilder: (ctx, i) {
                        final att = attendees[i];
                        final donor = att['donors'] as Map<String, dynamic>?;
                        final name = donor?['first_name'] ?? att['phone'] ?? 'Donor #${i + 1}';
                        final group = donor?['blood_group'] ?? 'O+';
                        final units = att['units'] ?? 1;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: BrandColors.greenTint,
                            child: Icon(Icons.check_rounded, color: BrandColors.green),
                          ),
                          title: Text(name, style: BrandTypography.headline(color: BrandColors.textPrimary)),
                          subtitle: Text('$group · $units unit donated', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                          trailing: const Text('VERIFIED', style: TextStyle(color: BrandColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                ActionButton(
                  label: 'DONE',
                  variant: ActionButtonVariant.primary,
                  height: 44,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      appBar: ScreenHeader(
        title: 'Camp Management',
        showBackButton: false,
        trailing: [
          IconButton(
            onPressed: () => _showCreateCampModal(context),
            icon: const Icon(Icons.add_circle_rounded, size: 28, color: BrandColors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingCamps
            ? const Center(child: CircularProgressIndicator(color: BrandColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '⛺',
                    text: 'Blood donation drives bring communities together. Organize camps and track donor RSVPs in Supabase!',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Camps in Supabase', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                          Text('${bankCamps.length} Drives Scheduled Across Regions', style: BrandTypography.caption(color: BrandColors.red)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showScheduleCampDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 16, color: BrandColors.red),
                        label: const Text('Schedule Drive', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: BrandColors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: BrandColors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...bankCamps.map((camp) {
                    final dateStr = '${camp.startsAt.day} ${_monthName(camp.startsAt.month)} ${camp.startsAt.year}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BrandColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: BrandColors.border,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  camp.title,
                                  style: BrandTypography.headline(color: BrandColors.textPrimary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BrandColors.redTint,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: BrandColors.redShadow, width: 1.0),
                                ),
                                child: Text(
                                  camp.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: BrandTypography.fontFamily,
                                    color: BrandColors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: BrandColors.red),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text('${camp.venue}, ${camp.area} (${camp.city})', style: BrandTypography.body(color: BrandColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('$dateStr · Target: ${camp.capacity} units', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: BrandColors.bgGrouped, borderRadius: BorderRadius.circular(4)),
                                child: Text('Radius: ${camp.targetRadiusKm.toInt()} km', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 10, color: BrandColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: camp.attendeesCheckedIn > 0 ? BrandColors.greenTint : BrandColors.bgGrouped,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: camp.attendeesCheckedIn > 0 ? BrandColors.greenShadow : BrandColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.how_to_reg_rounded,
                                      size: 14,
                                      color: camp.attendeesCheckedIn > 0 ? BrandColors.green : BrandColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${camp.attendeesCheckedIn} Checked In',
                                      style: TextStyle(
                                        fontFamily: BrandTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: camp.attendeesCheckedIn > 0 ? BrandColors.green : BrandColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BrandColors.redTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: BrandColors.redShadow, width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bloodtype_rounded, size: 14, color: BrandColors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${camp.unitsCollected} Units',
                                      style: const TextStyle(
                                        fontFamily: BrandTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: BrandColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ActionButton(
                                  label: 'CHECK-IN',
                                  icon: Icons.qr_code_scanner_rounded,
                                  variant: ActionButtonVariant.success,
                                  height: 40,
                                  onPressed: () => _showCampCheckInSheet(context, camp),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 3,
                                child: ActionButton(
                                  label: 'ROSTER',
                                  icon: Icons.people_outline_rounded,
                                  variant: ActionButtonVariant.secondary,
                                  height: 40,
                                  onPressed: () => _showCampRosterSheet(context, camp),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 3,
                                child: ActionButton(
                                  label: 'BROADCAST',
                                  icon: Icons.campaign_rounded,
                                  variant: ActionButtonVariant.primary,
                                  height: 40,
                                  onPressed: () => _showBankBroadcastSheet(context, camp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
