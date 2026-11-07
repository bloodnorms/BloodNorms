// ============================================================================
// BloodNorms | admin_console_screen.dart
// Modern Minimal Operations Command Center Screen
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
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.primaryAction,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        'Broadcast sent to $count donors in ${_controller.selectedTargetCity} within ${_controller.broadcastRadiusKm.toInt()} km ($suppressed suppressed, ₹$cost INR)',
      );
    } else if (res['requires_approval'] == true) {
      showFourEyesApprovalDialog(
        context: context,
        recipientCount: res['eligible_count'] ?? 0,
        onNavigateToApprovals: () => _controller.setActivePage('approvals_queue'),
      );
    }
  }

  void _openQuickActions() {
    showQuickActionsSheet(
      context: context,
      onNavigate: _controller.setActivePage,
      onToggleKillswitch: () async {
        await _controller.toggleKillSwitch(!_controller.killSwitchActive);
        _showToast(_controller.killSwitchActive
            ? 'Emergency killswitch activated'
            : 'Platform operations restored to normal');
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
        final mainCanvas = AdminWorkspaceCanvas(
          controller: _controller,
          onQuickActions: _openQuickActions,
          onDispatchBroadcast: _handleDispatchBroadcast,
          onShowToast: _showToast,
        );

        const loadingIndicator = Center(
          child: CircularProgressIndicator(color: BrandColors.primaryAction),
        );

        return Scaffold(
          backgroundColor: BrandColors.surfaceSoft,
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
                        child: _controller.isLoading ? loadingIndicator : mainCanvas,
                      ),
                    ],
                  )
                : Scaffold(
                    backgroundColor: BrandColors.surfaceSoft,
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: BrandColors.background,
                      foregroundColor: BrandColors.textPrimary,
                      iconTheme: const IconThemeData(color: BrandColors.textPrimary),
                      bottom: const PreferredSize(
                        preferredSize: Size.fromHeight(1.0),
                        child: Divider(height: 1, color: BrandColors.borderSubtle),
                      ),
                      title: Text(
                        AdminHeader.getPageTitle(_controller.activePage),
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.sync_rounded, color: BrandColors.textSecondary),
                          onPressed: () {
                            _controller.loadAllAdminData();
                            _showToast('Synced with database');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bolt_rounded, color: BrandColors.accent),
                          onPressed: _openQuickActions,
                        ),
                      ],
                    ),
                    drawer: Drawer(
                      backgroundColor: BrandColors.surfaceSoft,
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
                    body: _controller.isLoading ? loadingIndicator : mainCanvas,
                  ),
          ),
        );
      },
    );
  }
}
