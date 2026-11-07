// ============================================================================
// BloodNorms | scripts/test_whatsapp.dart
// Standalone Meta WhatsApp Cloud API Diagnostic & Live Dispatch Tool
// Usage: dart run scripts/test_whatsapp.dart [--phone 9052493747] [--template hello_world]
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  print('================================================================');
  print('    BLOODNORMS — META WHATSAPP CLOUD API VERIFICATION TOOL     ');
  print('================================================================\n');

  // 1. Load environment variables manually
  final envVars = <String, String>{};
  final envFiles = ['.env', 'assets/.env'];

  for (final file in envFiles) {
    final f = File(file);
    if (f.existsSync()) {
      print('✓ Found config file: $file');
      final lines = f.readAsLinesSync();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('#') && trimmed.contains('=')) {
          final idx = trimmed.indexOf('=');
          final key = trimmed.substring(0, idx).trim();
          final val = trimmed.substring(idx + 1).trim();
          if (!envVars.containsKey(key) || envVars[key]!.isEmpty) {
            envVars[key] = val;
          }
        }
      }
    }
  }

  final phoneId = envVars['WHATSAPP_PHONE_NUMBER_ID'] ?? '';
  final token = envVars['WHATSAPP_ACCESS_TOKEN'] ?? '';
  final wabaId = envVars['WHATSAPP_BUSINESS_ACCOUNT_ID'] ?? '';
  final webhookVerify = envVars['WHATSAPP_WEBHOOK_VERIFY_TOKEN'] ?? 'bloodnorms_wa_verify';

  // 2. Parse command-line flags
  String targetPhone = '919052493747'; // Default to Siva's phone
  String templateName = 'hello_world';

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--phone' && i + 1 < args.length) {
      targetPhone = args[i + 1].replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
      if (targetPhone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(targetPhone)) {
        targetPhone = '91$targetPhone';
      }
    } else if (args[i] == '--template' && i + 1 < args.length) {
      templateName = args[i + 1];
    }
  }

  print('\n------------------- CREDENTIALS DIAGNOSTIC -------------------');
  print('Target Recipient : +$targetPhone');
  print('Phone Number ID  : ${phoneId.isEmpty ? '[NOT SET]' : phoneId}');
  print('Access Token     : ${token.isEmpty ? '[NOT SET]' : '${token.substring(0, 6)}••••${token.substring(token.length - 4)}'}');
  print('WABA Account ID  : ${wabaId.isEmpty ? '[NOT SET]' : wabaId}');
  print('Webhook Verify   : $webhookVerify');
  print('--------------------------------------------------------------\n');

  // Check 1: Phone Number ID format
  if (phoneId.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phoneId)) {
    print('⚠️  WARNING: WHATSAPP_PHONE_NUMBER_ID is set to "$phoneId", which is a 10-digit Indian mobile number.');
    print('   In Meta WhatsApp Cloud API, "Phone Number ID" is a 15-to-16 digit Meta Graph API numeric ID.');
    print('   Where to find it:');
    print('   1. Open https://developers.facebook.com/apps');
    print('   2. Select your App -> Go to "WhatsApp" -> "API Setup"');
    print('   3. Look under "Step 1: Send and receive messages" for "Phone number ID" (e.g. 105493829104829)');
    print('');
  }

  // Check 2: Missing Access Token
  if (token.isEmpty) {
    print('❌ ERROR: WHATSAPP_ACCESS_TOKEN is missing in .env / assets/.env.');
    print('   To get an instant test token:');
    print('   1. Open https://developers.facebook.com/apps -> Your App -> WhatsApp -> API Setup');
    print('   2. Copy the "Temporary access token" (valid for 24h)');
    print('   3. Paste it into assets/.env: WHATSAPP_ACCESS_TOKEN=EAAB...');
    print('\nCannot proceed without an Access Token. Exiting.');
    exit(1);
  }

  if (phoneId.isEmpty) {
    print('❌ ERROR: WHATSAPP_PHONE_NUMBER_ID is missing in .env / assets/.env.');
    print('   Please enter your 15-digit Phone Number ID from Meta Developer Portal.');
    exit(1);
  }

  // 3. Dispatch Live Test Message via Meta Graph API v19.0
  print('🚀 Sending WhatsApp message via Meta Cloud API...');
  print('   Endpoint: https://graph.facebook.com/v19.0/$phoneId/messages');
  print('   Template: $templateName (en_US)');

  final url = Uri.parse('https://graph.facebook.com/v19.0/$phoneId/messages');
  final payload = {
    'messaging_product': 'whatsapp',
    'recipient_type': 'individual',
    'to': targetPhone,
    'type': 'template',
    'template': {
      'name': templateName,
      'language': {'code': 'en_US'},
    },
  };

  try {
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print('\n---------------------- META API RESPONSE ---------------------');
    print('HTTP Status Code : ${res.statusCode}');
    print('Response Body    : ${res.body}');
    print('--------------------------------------------------------------\n');

    final Map<String, dynamic> body = jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final messages = body['messages'] as List?;
      final messageId = messages?.first['id'];
      print('✅ SUCCESS! WhatsApp message was successfully accepted by Meta!');
      print('   Message ID: $messageId');
      print('   Check WhatsApp on phone: +$targetPhone\n');
    } else {
      final err = body['error'] as Map<String, dynamic>?;
      final code = err?['code'];
      final message = err?['message'];

      print('❌ FAILED: Meta rejected the request.');
      print('   Error Code : $code');
      print('   Details    : $message\n');

      if (code == 190) {
        print('💡 FIX: Your Access Token is expired or invalid.');
        print('   Regenerate a Temporary Token at https://developers.facebook.com/apps');
      } else if (code == 131030) {
        print('💡 FIX: Recipient +$targetPhone is not in your Meta Sandbox Allowed List.');
        print('   Go to WhatsApp -> API Setup -> Step 5: "Manage phone number list", add +$targetPhone and enter the OTP.');
      } else if (code == 100) {
        print('💡 FIX: Phone Number ID is invalid. Verify the 15-digit ID from Meta Developer Portal.');
      }
    }
  } catch (e) {
    print('❌ Network error contacting Meta Graph API: $e');
  }
}

