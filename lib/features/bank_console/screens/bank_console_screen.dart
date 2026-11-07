// ============================================================================
// BloodNorms | bank_console_screen.dart
// Blood Bank Console Screen — Thin Screen Composing Modular Tabs & Shell
// Orchestrates Stock, Confirm, Expected, Camps, and More tabs
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../widgets/index.dart';

class BankConsoleScreen extends StatefulWidget {
  const BankConsoleScreen({super.key});

  @override
  State<BankConsoleScreen> createState() => _BankConsoleScreenState();
}

class _BankConsoleScreenState extends State<BankConsoleScreen> {
  int _currentTab = 0;

  // Connected Banks
  List<Map<String, dynamic>> _banks = [];
  String _selectedBankId = 'b1000000-0000-0000-0000-000000000001';
  String _selectedBankName = 'GGH Blood Bank';

  // Stock State (8 groups x units)
  BloodComponentType _selectedComponent = BloodComponentType.wholeBlood;
  final Map<BloodGroup, int> _stock = {
    for (final bg in BloodGroup.values) bg: 0,
  };
  bool _isSavingStock = false;

  // Expected Donors & Camps from Supabase
  List<Map<String, dynamic>> _expectedDonors = [];
  List<CampModel> _bankCamps = [];
  bool _isLoadingExpected = false;
  bool _isLoadingCamps = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _loadExpectedDonors();
    _loadBankCamps();
  }

  Future<void> _loadBanks() async {
    final banks = await SupabaseService().getBanks();
    if (mounted && banks.isNotEmpty) {
      setState(() {
        _banks = banks;
        _selectedBankId = banks.first['id']?.toString() ?? _selectedBankId;
        _selectedBankName = banks.first['name']?.toString() ?? _selectedBankName;
      });
      _loadLiveStock();
    } else {
      _loadLiveStock();
    }
  }

  void _showBankSelector() {
    showBankSelectorSheet(
      context: context,
      banks: _banks,
      selectedBankId: _selectedBankId,
      onBankSelected: (id, name) {
        setState(() {
          _selectedBankId = id;
          _selectedBankName = name;
        });
        _loadLiveStock();
      },
    );
  }

  Future<void> _loadExpectedDonors() async {
    setState(() => _isLoadingExpected = true);
    final donors = await SupabaseService().getExpectedDonors();
    if (mounted) {
      setState(() {
        _expectedDonors = donors;
        _isLoadingExpected = false;
      });
    }
  }

  Future<void> _loadBankCamps() async {
    setState(() => _isLoadingCamps = true);
    final camps = await SupabaseService().getCamps();
    if (mounted) {
      setState(() {
        _bankCamps = camps;
        _isLoadingCamps = false;
      });
    }
  }

  Future<void> _loadLiveStock() async {
    final liveStock = await SupabaseService().getBankStock(
      bankId: _selectedBankId,
      component: _selectedComponent.code,
    );
    if (mounted && liveStock.isNotEmpty) {
      setState(() {
        for (var entry in liveStock.entries) {
          final group = BloodGroup.fromString(entry.key);
          if (group != null) {
            _stock[group] = entry.value;
          }
        }
      });
    }
  }

  Future<void> _saveStock() async {
    setState(() => _isSavingStock = true);
    final rows = _stock.entries.map((e) {
      return {
        'blood_group': e.key.label,
        'group': e.key.label,
        'component': _selectedComponent.code,
        'units': e.value,
      };
    }).toList();

    await SupabaseService().setBankStock(rows, bankId: _selectedBankId);
    setState(() => _isSavingStock = false);

    if (mounted) {
      _showToast('Blood bank stock updated successfully in Supabase!');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      body: IndexedStack(
        index: _currentTab,
        children: [
          StockTabView(
            selectedBankName: _selectedBankName,
            selectedComponent: _selectedComponent,
            stock: _stock,
            isSavingStock: _isSavingStock,
            onRefreshUnchanged: _saveStock,
            onShowBankSelector: _showBankSelector,
            onComponentChanged: (val) {
              setState(() => _selectedComponent = val);
              _loadLiveStock();
            },
            onIncrement: (group) {
              setState(() => _stock[group] = (_stock[group] ?? 0) + 1);
            },
            onDecrement: (group) {
              final current = _stock[group] ?? 0;
              if (current > 0) {
                setState(() => _stock[group] = current - 1);
              }
            },
            onSaveStock: _saveStock,
          ),
          ConfirmDonationTabView(
            onDonationConfirmed: () {
              _loadExpectedDonors();
              _loadLiveStock();
            },
          ),
          ExpectedDonorsTabView(
            expectedDonors: _expectedDonors,
            isLoadingExpected: _isLoadingExpected,
            onRefresh: _loadExpectedDonors,
          ),
          BankCampsTabView(
            bankCamps: _bankCamps,
            isLoadingCamps: _isLoadingCamps,
            selectedBankId: _selectedBankId,
            onCampUpdated: _loadBankCamps,
            onShowToast: _showToast,
          ),
          const BankMoreTabView(),
        ],
      ),
      bottomNavigationBar: BankConsoleNavBar(
        currentTab: _currentTab,
        onTabSelected: (index) => setState(() => _currentTab = index),
      ),
    );
  }
}
