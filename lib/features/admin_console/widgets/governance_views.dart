// ============================================================================
// BloodNorms | governance_views.dart
// Governance, Approvals, Data Exports, DPDP Registry, Killswitch & Audit Logs
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class GovernanceViews extends StatelessWidget {
  final String subPage;
  final List<Map<String, dynamic>> approvalRequests;
  final List<Map<String, dynamic>> dataExports;
  final List<Map<String, dynamic>> dpdpRequests;
  final bool killSwitchActive;
  final List<Map<String, dynamic>> safetyIncidents;
  final List<Map<String, dynamic>> auditLogs;
  final void Function(String id, bool approve) onDecideApproval;
  final void Function(bool val) onToggleKillSwitch;
  final void Function(String message) onShowToast;

  const GovernanceViews({
    super.key,
    required this.subPage,
    required this.approvalRequests,
    required this.dataExports,
    required this.dpdpRequests,
    required this.killSwitchActive,
    required this.safetyIncidents,
    required this.auditLogs,
    required this.onDecideApproval,
    required this.onToggleKillSwitch,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    switch (subPage) {
      case 'approvals_queue':
        return _buildApprovalsQueuePage();
      case 'data_exports':
        return _buildDataExportsPage(context);
      case 'dpdp_registry':
        return _buildDPDPRegistryPage();
      case 'settings_killswitch':
        return _buildKillswitchPage();
      case 'settings_algorithm':
        return _buildAlgorithmPage();
      case 'settings_safety':
        return _buildSafetyDeskPage();
      case 'settings_audit':
      default:
        return _buildAuditLogsPage();
    }
  }

  Widget _buildApprovalsQueuePage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: approvalRequests.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Zero pending Four-Eyes approval requests', style: TextStyle(color: BrandColors.textSecondary))))
          : ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: approvalRequests.map((a) {
                final id = a['id']?.toString() ?? '';
                final action = a['action_type'] ?? 'broadcast.mass';
                final reason = a['reason'] ?? 'Emergency mobilization';
                final maker = a['maker_id'] ?? 'admin-01';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$action (#${id.substring(0, id.length > 8 ? 8 : id.length)})', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Maker: $maker · Reason: $reason', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => onDecideApproval(id, true),
                            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.green, foregroundColor: Colors.white),
                            child: const Text('Approve (Checker)'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => onDecideApproval(id, false),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDataExportsPage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Privacy-Governed DPDP Data Exports', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Generates SHA-256 watermarked CSV files. Donor health questions are strictly unreadable per Section 0.3.', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final res = await SupabaseService().createDataExport(
                entityType: 'donors',
                tier: '2',
                format: 'csv',
                reason: 'Routine quarterly audit export for health authorities',
              );
              if (res['ok'] == true && context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Export Generated (CSV)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold)),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File: ${res['filename']}'),
                          Text('Watermark: ${res['watermark_hash']}'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Text('id,name,phone,blood_group,city\n#101,Suresh M.,+91******3210,O+,Rajahmundry\n#102,K. Ravi,+91******4321,B+,Rajahmundry', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: 'id,name,phone,blood_group,city\n#101,Suresh M.,+91******3210,O+,Rajahmundry\n#102,K. Ravi,+91******4321,B+,Rajahmundry'));
                          Navigator.pop(ctx);
                          onShowToast('CSV contents copied to clipboard!');
                        },
                        child: const Text('Copy CSV'),
                      ),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.file_download_rounded, size: 16),
            label: const Text('Generate Masked Donors CSV Export'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text('Export Records on Ledger:', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          ...dataExports.map((e) => ListTile(
                dense: true,
                leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF0891B2)),
                title: Text(e['filename']?.toString() ?? 'export.csv', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold)),
                subtitle: Text('SHA-256: ${e['watermark_hash']?.toString().substring(0, 10)}...'),
                trailing: const Text('READY', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.green, fontSize: 11)),
              )),
        ],
      ),
    );
  }

  Widget _buildDPDPRegistryPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Digital Personal Data Protection (DPDP) Erasure Requests', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...dpdpRequests.map((d) => ListTile(
                dense: true,
                leading: const Icon(Icons.person_off_rounded, color: BrandColors.red),
                title: Text('Right-to-be-Forgotten (#${d['id']?.toString().substring(0, 6)})', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Phone: ${d['phone_masked']} · Channel: ${d['request_type']}'),
                trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: BrandColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('PROCESSED', style: TextStyle(color: BrandColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
              )),
        ],
      ),
    );
  }

  Widget _buildKillswitchPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: killSwitchActive ? BrandColors.redTint : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: killSwitchActive ? BrandColors.red : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.power_settings_new_rounded, color: BrandColors.red, size: 22),
                      SizedBox(width: 8),
                      Text('MASTER PLATFORM KILL SWITCH', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.red, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    killSwitchActive ? 'ACTIVE: Outbound calls and intake are paused in Supabase' : 'Normal operations running smoothly on ixrborkhofxlxbedpang',
                    style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: killSwitchActive,
              activeThumbColor: BrandColors.red,
              onChanged: onToggleKillSwitch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Algorithm Parameters (BR-06..BR-08)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          Text('• Wave 1 Initial Radius: 1.5 km (3 nearby verified donors)\n• Wave 2 Expansion: +2.0 km (Total 3.5 km)\n• Wave 3 Expansion: +2.0 km (Total 5.5 km)\n• Max Geofence Cap: 15.0 km\n• Gates: Telephony gates enforced at 70km, 90km, 100km per BR-07.\n• Donor Cooldown Period: 90 days between donations.'),
        ],
      ),
    );
  }

  Widget _buildSafetyDeskPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clinical Safety & Adverse Donor Incidents Desk', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...safetyIncidents.map((inc) => ListTile(
                dense: true,
                leading: const Icon(Icons.healing_rounded, color: BrandColors.red),
                title: Text('${inc['title']} (${inc['severity']})', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${inc['description']} · Status: ${inc['status']}'),
                trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: BrandColors.greenTint, borderRadius: BorderRadius.circular(4)), child: const Text('CLOSED', style: TextStyle(color: BrandColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
              )),
        ],
      ),
    );
  }

  Widget _buildAuditLogsPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cryptographically Logged Audit Feed', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${auditLogs.length} Events', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ...auditLogs.map((log) => ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(log['time'] ?? 'Recent', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: BrandColors.textSecondary)),
                ),
                title: Text(log['action'] ?? 'action', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: BrandColors.red)),
                subtitle: Text(log['detail'] ?? '', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12)),
              )),
        ],
      ),
    );
  }
}
