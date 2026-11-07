// ============================================================================
// BloodNorms | admin_console_screen.dart
// Executive Operations & Superhero Admin Command Center Screen
// Thin Screen Composing Modular Widgets, Sidebar, Header & Workspace Router
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../controllers/admin_console_controller.dart';
import '../widgets/index.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  late final AdminConsoleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminConsoleController();
    _controller.loadAllAdminData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleDispatchBroadcast() async {
    final title = _controller.broadcastTitleController.text.trim();
    final message = _controller.broadcastMsgController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showToast('Please enter both broadcast title and message text.');
      return;
    }

    final res = await _controller.dispatchBroadcast();
    if (!mounted) return;

    if (res['success'] == true) {
      final count = res['recipients'] ?? 0;
      final suppressed = res['suppressed'] ?? 0;
      final cost = res['cost_inr'] ?? 0.0;
      _showToast(
        '🚀 Broadcast sent to $count donors in ${_controller.selectedTargetCity} within ${_controller.broadcastRadiusKm.toInt()} km! ($suppressed suppressed, ₹$cost INR)',
      );
    } else if (res['requires_approval'] == true) {
      final count = res['eligible_count'] ?? 0;
      _showFourEyesDialog(count);
    }
  }

  void _showFourEyesDialog(int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.rule_folder_outlined, color: BrandColors.red),
            SizedBox(width: 8),
            Text(
              'Four-Eyes Approval Required',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Broadcasting to $count recipients exceeds single-admin threshold (>200 donors).\n\nRouted to Four-Eyes Approvals Desk for second-admin verification.',
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.setActivePage('approvals_queue');
            },
            child: const Text(
              'Go to Approvals Queue',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                color: BrandColors.red,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Acknowledged'),
          ),
        ],
      ),
    );
  }

  void _openQuickActions() {
    showQuickActionsSheet(
      context: context,
      onNavigate: _controller.setActivePage,
      onToggleKillswitch: () async {
        await _controller.toggleKillSwitch(!_controller.killSwitchActive);
        _showToast(_controller.killSwitchActive
            ? '🚨 PLATFORM EMERGENCY KILL-SWITCH ACTIVATED'
            : '✅ Platform operations restored to normal');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showPermanentSidebar = width >= 720;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          body: SafeArea(
            child: showPermanentSidebar
                ? Row(
                    children: [
                      AdminSidebar(
                        activePage: _controller.activePage,
                        isSidebarCompact: _controller.isSidebarCompact,
                        expandedCategories: _controller.expandedCategories,
                        onPageSelected: _controller.setActivePage,
                        onToggleCompact: _controller.toggleSidebarCompact,
                        onToggleCategory: _controller.toggleCategory,
                        isPermanent: true,
                      ),
                      Expanded(
                        child: _controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: BrandColors.red,
                                ),
                              )
                            : _buildMainWorkspaceCanvas(),
                      ),
                    ],
                  )
                : Scaffold(
                    backgroundColor: const Color(0xFFF4F6FB),
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: const Color(0xFF121316),
                      iconTheme: const IconThemeData(color: Colors.white),
                      title: Text(
                        AdminHeader.getPageTitle(_controller.activePage),
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.sync_rounded, color: Colors.white),
                          onPressed: () {
                            _controller.loadAllAdminData();
                            _showToast('Synced with Supabase');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bolt_rounded,
                              color: BrandColors.red),
                          onPressed: _openQuickActions,
                        ),
                      ],
                    ),
                    drawer: Drawer(
                      child: AdminSidebar(
                        activePage: _controller.activePage,
                        isSidebarCompact: false,
                        expandedCategories: _controller.expandedCategories,
                        onPageSelected: _controller.setActivePage,
                        onToggleCompact: () {},
                        onToggleCategory: _controller.toggleCategory,
                        isPermanent: false,
                      ),
                    ),
                    body: _controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: BrandColors.red,
                            ),
                          )
                        : _buildMainWorkspaceCanvas(),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMainWorkspaceCanvas() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        AdminHeader(
          activePage: _controller.activePage,
          onQuickActions: _openQuickActions,
        ),
        const SizedBox(height: 20),
        AdminWorkspaceRouter(
          activePage: _controller.activePage,
          liveRequests: _controller.liveRequests,
          banksList: _controller.banksList,
          donorsList: _controller.donorsList,
          campsList: _controller.campsList,
          dailySpend: _controller.dailySpend,
          audiencePreview: _controller.audiencePreview,
          broadcastHistory: _controller.broadcastHistory,
          selectedTargetCity: _controller.selectedTargetCity,
          selectedChannel: _controller.selectedChannel,
          broadcastRadiusKm: _controller.broadcastRadiusKm,
          respectDonorTravelRadius: _controller.respectDonorTravelRadius,
          broadcastTitleController: _controller.broadcastTitleController,
          broadcastMsgController: _controller.broadcastMsgController,
          isBroadcasting: _controller.isBroadcasting,
          hospitalsList: _controller.hospitalsList,
          requestersList: _controller.requestersList,
          partnersList: _controller.partnersList,
          approvalRequests: _controller.approvalRequests,
          dataExports: _controller.dataExports,
          dpdpRequests: _controller.dpdpRequests,
          killSwitchActive: _controller.killSwitchActive,
          safetyIncidents: _controller.safetyIncidents,
          auditLogs: _controller.auditLogs,
          stockMatrix: _controller.stockMatrix,
          onWidenRequest: (id, km) {
            _controller.widenRequest(id, km);
            _showToast('Expanded search ring to ${(km + 2.0).toStringAsFixed(1)} km (+3 donors contacted)');
          },
          onCloseRequest: (id) {
            _controller.closeRequest(id);
            _showToast('Emergency crisis fulfilled and closed');
          },
          onNavigate: _controller.setActivePage,
          onCityChanged: _controller.setTargetCity,
          onChannelChanged: _controller.setChannel,
          onRadiusChanged: _controller.setBroadcastRadius,
          onRespectRadiusChanged: _controller.setRespectTravelRadius,
          onDispatchBroadcast: _handleDispatchBroadcast,
          onCampSelectedForBroadcast: _controller.selectCampForBroadcast,
          onCampCreated: _controller.addCamp,
          onAdjustStock: (group, delta) {
            _controller.adjustStockDirect(group, delta);
            _showToast('${delta > 0 ? "+$delta" : delta} units of $group adjusted in database');
          },
          onToggleDonorPause: (id, state) async {
            await _controller.toggleDonorPause(id, state);
            final next = state == 'active' ? 'PAUSED' : 'ACTIVE';
            _showToast('Donor status updated to $next');
          },
          onToggleRequesterBlock: (phone, blocked) async {
            await _controller.toggleRequesterBlock(phone, blocked);
            _showToast(blocked ? 'Unblocked $phone' : 'Blocked $phone from emergency broadcast');
          },
          onDecideApproval: (id, approve) async {
            final res = await _controller.decideApproval(id, approve);
            if (res['ok'] == true) {
              _showToast(approve ? 'Approved change request #$id' : 'Rejected change request #$id');
            } else {
              _showToast('Approval action failed: ${res['reason']}');
            }
          },
          onToggleKillSwitch: (val) async {
            await _controller.toggleKillSwitch(val);
            _showToast(val
                ? '🚨 PLATFORM EMERGENCY KILL-SWITCH ACTIVATED'
                : '✅ Platform operations restored to normal');
          },
          onShowToast: _showToast,
        ),
      ],
    );
  }
}
