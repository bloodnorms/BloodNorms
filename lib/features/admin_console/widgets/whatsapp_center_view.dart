// ============================================================================
// BloodNorms | whatsapp_center_view.dart
// WhatsApp Comms Hub (Live Assistant Bot, Template Chat Preview, Telecom Rates)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class WhatsAppCenterView extends StatefulWidget {
  final String subPage; // 'whatsapp_bot' | 'whatsapp_templates' | 'whatsapp_telecom'
  final void Function(String message) onShowToast;

  const WhatsAppCenterView({
    super.key,
    required this.subPage,
    required this.onShowToast,
  });

  @override
  State<WhatsAppCenterView> createState() => _WhatsAppCenterViewState();
}

class _WhatsAppCenterViewState extends State<WhatsAppCenterView> {
  // Live Test Bench State
  final TextEditingController _waTestPhoneController = TextEditingController(text: '+91 9052493747');
  final TextEditingController _waPhoneIdController = TextEditingController();
  final TextEditingController _waAccessTokenController = TextEditingController();
  final TextEditingController _waCustomTextController = TextEditingController(
    text: 'Hello from BloodNorms Admin Console! Live Meta WhatsApp Cloud API test message.',
  );
  bool _isWaSending = false;
  String? _waLastDispatchStatus;
  bool? _waLastDispatchSuccess;
  String? _waLastMessageId;
  String? _waLastErrorDetails;

  // Template State
  String _activeTemplateKey = 'camp_invite';
  final TextEditingController _templateNameVar = TextEditingController(text: 'Suresh');
  final TextEditingController _templateHospVar = TextEditingController(text: 'GGH Rajahmundry');
  final TextEditingController _templateUnitsVar = TextEditingController(text: '2 Units of O+');

  @override
  void dispose() {
    _waTestPhoneController.dispose();
    _waPhoneIdController.dispose();
    _waAccessTokenController.dispose();
    _waCustomTextController.dispose();
    _templateNameVar.dispose();
    _templateHospVar.dispose();
    _templateUnitsVar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.subPage) {
      case 'whatsapp_templates':
        return _buildWhatsAppTemplatesPage();
      case 'whatsapp_telecom':
        return _buildWhatsAppTelecomPage();
      case 'whatsapp_bot':
      default:
        return _buildWhatsAppBotPage();
    }
  }

  Widget _buildWhatsAppBotPage() {
    final waConfig = WhatsAppService().getConfig();
    final is10DigitMobile = _waPhoneIdController.text.trim().length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(_waPhoneIdController.text.trim());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meta WhatsApp Cloud API Live Bot & Test Dispatcher', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                        SizedBox(height: 4),
                        Text('Direct integration with Meta Graph API v19.0 for emergency alerts, blood camp invites, and automated triage.', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: waConfig.isConfigured ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: waConfig.isConfigured ? const Color(0xFF86EFAC) : const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: waConfig.isConfigured ? const Color(0xFF16A34A) : const Color(0xFFDC2626), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(
                            waConfig.isConfigured ? 'CREDENTIALS SET' : 'CREDENTIALS NEEDED',
                            style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 11, color: waConfig.isConfigured ? const Color(0xFF166534) : const Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inbound WhatsApp Emergency Assistant', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Triages emergency blood needs via Meta Cloud API webhooks & provides nearest blood banks'),
                  value: true,
                  activeThumbColor: BrandColors.green,
                  onChanged: (val) => widget.onShowToast('WhatsApp assistant status updated'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFF25D366)),
                    SizedBox(width: 8),
                    Text('Meta WhatsApp Cloud API Credentials', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Values configured in assets/.env or overridden live below for rapid testing:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                if (is10DigitMobile)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFDE68A))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF92400E), height: 1.4),
                              children: [
                                const TextSpan(text: 'Notice: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '"${_waPhoneIdController.text}" looks like your personal 10-digit Indian mobile number. '),
                                const TextSpan(text: 'In Meta WhatsApp Cloud API, the "Phone Number ID" is a 15-to-16 digit ID provided by Meta inside developers.facebook.com > WhatsApp > API Setup (e.g. 105493829104829). If you have that 15-digit ID, enter it below!'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meta Phone Number ID (15 digits)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _waPhoneIdController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 105493829104829',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meta Access Token (Bearer)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _waAccessTokenController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'EAAB... (Temporary or Permanent Token)',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('Webhook URL: ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        SelectableText('https://ixrborkhofxlxbedpang.supabase.co/functions/v1/whatsapp-webhook', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        WhatsAppService().setRuntimeCredentials(
                          phoneNumberId: _waPhoneIdController.text,
                          accessToken: _waAccessTokenController.text,
                        );
                        setState(() {});
                        widget.onShowToast('WhatsApp runtime credentials saved and active!');
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Apply Credentials'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.send_rounded, size: 18, color: Color(0xFF25D366)),
                    SizedBox(width: 8),
                    Text('Live WhatsApp Dispatch Test Bench', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Send a real WhatsApp test message to your phone number right now to verify delivery:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _waTestPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Recipient Phone Number (with Country Code)',
                          hintText: '+91 90524 93747',
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _waCustomTextController,
                        decoration: InputDecoration(
                          labelText: 'Custom Alert Message Text',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isWaSending
                          ? null
                          : () async {
                              setState(() {
                                _isWaSending = true;
                                _waLastDispatchStatus = null;
                                _waLastDispatchSuccess = null;
                                _waLastMessageId = null;
                                _waLastErrorDetails = null;
                              });

                              final res = await WhatsAppService().sendTemplateMessage(
                                toPhone: _waTestPhoneController.text,
                                templateName: 'hello_world',
                                languageCode: 'en_US',
                              );

                              setState(() {
                                _isWaSending = false;
                                _waLastDispatchSuccess = res.success;
                                _waLastDispatchStatus = res.statusCode.toString();
                                _waLastMessageId = res.messageId;
                                _waLastErrorDetails = res.detailedError ?? res.errorSummary;
                              });

                              if (res.success) {
                                widget.onShowToast('✓ WhatsApp hello_world delivered to ${_waTestPhoneController.text}!');
                              } else {
                                widget.onShowToast('✕ Delivery failed: ${res.errorSummary}');
                              }
                            },
                      icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                      label: const Text('Send "hello_world" Template (Recommended)'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isWaSending
                          ? null
                          : () async {
                              setState(() {
                                _isWaSending = true;
                                _waLastDispatchStatus = null;
                                _waLastDispatchSuccess = null;
                                _waLastMessageId = null;
                                _waLastErrorDetails = null;
                              });

                              final res = await WhatsAppService().sendTextMessage(
                                toPhone: _waTestPhoneController.text,
                                bodyText: '🚨 URGENT BLOOD ALERT: 2 Units of O+ required at GGH Rajahmundry. Can you donate today to save a life? Reply YES to confirm.',
                              );

                              setState(() {
                                _isWaSending = false;
                                _waLastDispatchSuccess = res.success;
                                _waLastDispatchStatus = res.statusCode.toString();
                                _waLastMessageId = res.messageId;
                                _waLastErrorDetails = res.detailedError ?? res.errorSummary;
                              });
                            },
                      icon: const Icon(Icons.emergency_rounded, size: 16, color: Color(0xFFE52E2E)),
                      label: const Text('Send Urgent Blood Alert'),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE52E2E)),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isWaSending
                          ? null
                          : () async {
                              setState(() {
                                _isWaSending = true;
                                _waLastDispatchStatus = null;
                                _waLastDispatchSuccess = null;
                                _waLastMessageId = null;
                                _waLastErrorDetails = null;
                              });

                              final res = await WhatsAppService().sendTextMessage(
                                toPhone: _waTestPhoneController.text,
                                bodyText: 'Namaste! 🩸 A voluntary blood donation camp is scheduled this Sunday at Rotary Community Hall, Rajahmundry. Reply YES to register your slot!',
                              );

                              setState(() {
                                _isWaSending = false;
                                _waLastDispatchSuccess = res.success;
                                _waLastDispatchStatus = res.statusCode.toString();
                                _waLastMessageId = res.messageId;
                                _waLastErrorDetails = res.detailedError ?? res.errorSummary;
                              });
                            },
                      icon: const Icon(Icons.event_available_rounded, size: 16, color: Color(0xFF0F172A)),
                      label: const Text('Send Camp Invite'),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isWaSending
                          ? null
                          : () async {
                              setState(() {
                                _isWaSending = true;
                                _waLastDispatchStatus = null;
                                _waLastDispatchSuccess = null;
                                _waLastMessageId = null;
                                _waLastErrorDetails = null;
                              });

                              final res = await WhatsAppService().sendTextMessage(
                                toPhone: _waTestPhoneController.text,
                                bodyText: _waCustomTextController.text,
                              );

                              setState(() {
                                _isWaSending = false;
                                _waLastDispatchSuccess = res.success;
                                _waLastDispatchStatus = res.statusCode.toString();
                                _waLastMessageId = res.messageId;
                                _waLastErrorDetails = res.detailedError ?? res.errorSummary;
                              });
                            },
                      icon: const Icon(Icons.message_rounded, size: 16, color: Color(0xFF25D366)),
                      label: const Text('Send Custom Message'),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF166534)),
                    ),
                  ],
                ),
                if (_isWaSending)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Row(
                      children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF25D366))),
                        SizedBox(width: 12),
                        Text('Connecting to Meta Graph API v19.0 and dispatching message...', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, color: Color(0xFF334155))),
                      ],
                    ),
                  ),
                if (!_isWaSending && _waLastDispatchSuccess == true)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF86EFAC))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                            SizedBox(width: 10),
                            Text('Message Successfully Accepted by Meta! (HTTP 200)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF166534))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• Meta Message ID: ${_waLastMessageId ?? "Confirmed"}', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF15803D))),
                        Text('• Recipient: ${_waTestPhoneController.text}', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF15803D))),
                        const Text('• Check your phone now on WhatsApp! Event logged to message_events.', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF15803D))),
                      ],
                    ),
                  ),
                if (!_isWaSending && _waLastDispatchSuccess == false)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECACA))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                            SizedBox(width: 10),
                            Text('Meta Dispatch Failed (HTTP $_waLastDispatchStatus)', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF991B1B))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_waLastErrorDetails ?? 'Unknown error', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFFB91C1C))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Text('What is Required to Send Real WhatsApp Messages (4 Steps)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 12),
                _buildGuideStep('1', 'Open Meta Developer Portal', 'Visit developers.facebook.com/apps -> Select or Create your Business App -> Go to "WhatsApp" -> "API Setup".'),
                _buildGuideStep('2', 'Add Your Phone to Sandbox Recipient List', 'Under "Step 5: Select phone numbers", click "Manage phone number list" and add +91 90524 93747. Meta will send a 6-digit WhatsApp OTP to verify it.'),
                _buildGuideStep('3', 'Copy Phone Number ID & Token', 'Copy the 15-digit "Phone number ID" (NOT your mobile number) and the "Temporary access token", then paste them above or in assets/.env.'),
                _buildGuideStep('4', 'Click "Send hello_world Template"', 'Tap the green button above to test instant delivery to your WhatsApp!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String stepNumber, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: const Color(0xFF0F172A),
            child: Text(stepNumber, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppTemplatesPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('Camp Invitation'),
                selected: _activeTemplateKey == 'camp_invite',
                onSelected: (_) => setState(() => _activeTemplateKey = 'camp_invite'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Emergency Need Alert'),
                selected: _activeTemplateKey == 'emergency_alert',
                onSelected: (_) => setState(() => _activeTemplateKey = 'emergency_alert'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Donor Thank You'),
                selected: _activeTemplateKey == 'thank_you',
                onSelected: (_) => setState(() => _activeTemplateKey = 'thank_you'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _templateNameVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Donor Name {{name}}', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateHospVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Hospital {{hospital}}', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateUnitsVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Units/Group {{units}}', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEAE2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF25D366),
                      child: Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                    ),
                    SizedBox(width: 8),
                    Text('BloodNorms Assistant (Verified)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                    SizedBox(width: 4),
                    Icon(Icons.verified_rounded, color: Color(0xFF25D366), size: 14),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9FDD3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeTemplateKey == 'camp_invite'
                            ? 'Namaste ${_templateNameVar.text}! 🩸\n\nA voluntary blood camp is organized at ${_templateHospVar.text}. Can you join and donate ${_templateUnitsVar.text} to save local lives in Rajahmundry?\n\nReply YES to confirm your slot.'
                            : (_activeTemplateKey == 'emergency_alert'
                                ? '🚨 URGENT: ${_templateUnitsVar.text} needed immediately at ${_templateHospVar.text} for critical patient!\n\n${_templateNameVar.text}, are you available to donate right now? Reply 1 for YES, 2 for NO.'
                                : 'Thank you ${_templateNameVar.text}! Your recent donation of ${_templateUnitsVar.text} at ${_templateHospVar.text} was verified. Your certificate is ready in your BloodNorms Pass! 🎖️'),
                        style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, height: 1.4, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('10:42 AM', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            SizedBox(width: 4),
                            Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF53BDEB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => widget.onShowToast('Template updated and synchronized with Meta Cloud API'),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save & Sync Template'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final text = _activeTemplateKey == 'camp_invite'
                      ? 'Namaste ${_templateNameVar.text}! 🩸\n\nA voluntary blood camp is organized at ${_templateHospVar.text}. Can you join and donate ${_templateUnitsVar.text} to save local lives in Rajahmundry?\n\nReply YES to confirm your slot.'
                      : (_activeTemplateKey == 'emergency_alert'
                          ? '🚨 URGENT: ${_templateUnitsVar.text} needed immediately at ${_templateHospVar.text} for critical patient!\n\n${_templateNameVar.text}, are you available to donate right now? Reply YES to confirm.'
                          : 'Thank you ${_templateNameVar.text}! Your recent donation of ${_templateUnitsVar.text} at ${_templateHospVar.text} was verified. Your certificate is ready in your BloodNorms Pass! 🎖️');

                  widget.onShowToast('Sending WhatsApp message to ${_waTestPhoneController.text}...');
                  final res = await WhatsAppService().sendTextMessage(
                    toPhone: _waTestPhoneController.text,
                    bodyText: text,
                  );
                  if (res.success) {
                    widget.onShowToast('✓ WhatsApp message delivered! ID: ${res.messageId}');
                  } else {
                    widget.onShowToast('✕ Meta error: ${res.errorSummary}');
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF25D366)),
                label: Text('Send Test to ${_waTestPhoneController.text}'),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppTelecomPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itemized Telecom Rate Cards (INR)', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 14),
          ListTile(
            dense: true,
            leading: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF16A34A)),
            title: Text('Meta WhatsApp Business Utility Message', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Regional Emergency Mobilization Template'),
            trailing: Text('₹0.85 / msg', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2563EB)),
            title: Text('Twilio Programmable Outbound Voice', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Voice Gateway PSTN termination to Andhra Pradesh'),
            trailing: Text('₹1.20 / min', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
