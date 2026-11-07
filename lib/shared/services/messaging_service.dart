// ============================================================================
// BloodNorms | lib/core/services/whatsapp_service.dart
// Meta WhatsApp Cloud API Service: Direct Dispatch, Test Bench, & Webhook Helper
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bloodnorms/core/services/supabase_service.dart';

class WhatsAppConfigSummary {
  final String phoneNumberId;
  final String businessAccountId;
  final String accessToken;
  final String webhookVerifyToken;
  final bool isConfigured;
  final bool isPhoneNumberIdLikelyMobile;
  final String maskedToken;

  const WhatsAppConfigSummary({
    required this.phoneNumberId,
    required this.businessAccountId,
    required this.accessToken,
    required this.webhookVerifyToken,
    required this.isConfigured,
    required this.isPhoneNumberIdLikelyMobile,
    required this.maskedToken,
  });
}

class WhatsAppDispatchResult {
  final bool success;
  final int statusCode;
  final String? messageId;
  final String? errorSummary;
  final String? detailedError;
  final Map<String, dynamic>? rawResponse;

  const WhatsAppDispatchResult({
    required this.success,
    required this.statusCode,
    this.messageId,
    this.errorSummary,
    this.detailedError,
    this.rawResponse,
  });

  @override
  String toString() {
    if (success) {
      return 'Success (HTTP $statusCode): Message ID: $messageId';
    }
    return 'Failed (HTTP $statusCode): $errorSummary';
  }
}

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  static const String _graphApiVersion = 'v19.0';
  static const String _graphApiBase = 'https://graph.facebook.com/$_graphApiVersion';

  // In-memory runtime overrides for testing without app restart
  String? _runtimePhoneNumberId;
  String? _runtimeAccessToken;
  String? _runtimeBusinessAccountId;

  void setRuntimeCredentials({String? phoneNumberId, String? accessToken, String? businessAccountId}) {
    if (phoneNumberId != null) _runtimePhoneNumberId = phoneNumberId.trim();
    if (accessToken != null) _runtimeAccessToken = accessToken.trim();
    if (businessAccountId != null) _runtimeBusinessAccountId = businessAccountId.trim();
  }

  /// Get current WhatsApp Cloud API configuration
  WhatsAppConfigSummary getConfig() {
    final phoneId = _runtimePhoneNumberId ??
        (dotenv.isInitialized ? dotenv.env['WHATSAPP_PHONE_NUMBER_ID']?.trim() : null) ??
        '';

    final token = _runtimeAccessToken ??
        (dotenv.isInitialized ? dotenv.env['WHATSAPP_ACCESS_TOKEN']?.trim() : null) ??
        '';

    final wabaId = _runtimeBusinessAccountId ??
        (dotenv.isInitialized ? dotenv.env['WHATSAPP_BUSINESS_ACCOUNT_ID']?.trim() : null) ??
        '';

    final verify = (dotenv.isInitialized ? dotenv.env['WHATSAPP_WEBHOOK_VERIFY_TOKEN']?.trim() : null) ??
        'bloodnorms_wa_verify';

    final isLikelyMobile = phoneId.isNotEmpty &&
        (phoneId.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phoneId));

    String masked = 'Not Set';
    if (token.isNotEmpty) {
      if (token.length > 12) {
        masked = '${token.substring(0, 6)}••••${token.substring(token.length - 4)}';
      } else {
        masked = '••••••••';
      }
    }

    final configured = phoneId.isNotEmpty && token.isNotEmpty;

    return WhatsAppConfigSummary(
      phoneNumberId: phoneId,
      businessAccountId: wabaId,
      accessToken: token,
      webhookVerifyToken: verify,
      isConfigured: configured,
      isPhoneNumberIdLikelyMobile: isLikelyMobile,
      maskedToken: masked,
    );
  }

  /// Normalize phone number to Meta's expected digits-only format with country code (e.g. 919052493747)
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      cleaned = '91$cleaned';
    }
    return cleaned;
  }

  /// Mask phone number for DPDP compliance logging (e.g. +91 90524 •••••)
  static String maskPhoneForAudit(String phone) {
    final cleaned = normalizePhone(phone);
    if (cleaned.length >= 10) {
      final prefix = cleaned.substring(0, cleaned.length - 5);
      return '+$prefix •••••';
    }
    return '••••••••••';
  }

  /// Send a pre-approved template message (e.g. 'hello_world' or BloodNorms templates)
  Future<WhatsAppDispatchResult> sendTemplateMessage({
    required String toPhone,
    required String templateName,
    String languageCode = 'en_US',
    List<String>? bodyParameters,
  }) async {
    final config = getConfig();

    if (!config.isConfigured) {
      return WhatsAppDispatchResult(
        success: false,
        statusCode: 400,
        errorSummary: 'WhatsApp Cloud API is not configured. Missing Phone Number ID or Access Token.',
        detailedError: config.isPhoneNumberIdLikelyMobile
            ? 'Note: WHATSAPP_PHONE_NUMBER_ID is set to a 10-digit mobile number (${config.phoneNumberId}). It must be Meta\'s 15-digit Phone Number ID from developers.facebook.com.'
            : 'Please set WHATSAPP_PHONE_NUMBER_ID and WHATSAPP_ACCESS_TOKEN in assets/.env.',
      );
    }

    final toClean = normalizePhone(toPhone);
    final endpoint = Uri.parse('$_graphApiBase/${config.phoneNumberId}/messages');

    final Map<String, dynamic> templatePayload = {
      'name': templateName,
      'language': {'code': languageCode},
    };

    if (bodyParameters != null && bodyParameters.isNotEmpty) {
      templatePayload['components'] = [
        {
          'type': 'body',
          'parameters': bodyParameters.map((p) => {'type': 'text', 'text': p}).toList(),
        }
      ];
    }

    final Map<String, dynamic> requestBody = {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': toClean,
      'type': 'template',
      'template': templatePayload,
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer ${config.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final result = _parseMetaResponse(response.statusCode, response.body);

      // Log event into audit & message_events
      await _logOutboundEvent(
        toClean: toClean,
        eventType: 'template_$templateName',
        success: result.success,
        statusCode: response.statusCode,
        messageId: result.messageId,
        error: result.errorSummary,
      );

      return result;
    } catch (e) {
      final errorResult = WhatsAppDispatchResult(
        success: false,
        statusCode: 0,
        errorSummary: 'Network error connecting to Meta Graph API: $e',
        detailedError: e.toString(),
      );

      await _logOutboundEvent(
        toClean: toClean,
        eventType: 'template_$templateName',
        success: false,
        statusCode: 0,
        error: e.toString(),
      );

      return errorResult;
    }
  }

  /// Send a free-form text message (Valid within 24 hours of customer inbound message, or in Sandbox mode)
  Future<WhatsAppDispatchResult> sendTextMessage({
    required String toPhone,
    required String bodyText,
  }) async {
    final config = getConfig();

    if (!config.isConfigured) {
      return WhatsAppDispatchResult(
        success: false,
        statusCode: 400,
        errorSummary: 'WhatsApp Cloud API is not configured. Missing Phone Number ID or Access Token.',
        detailedError: config.isPhoneNumberIdLikelyMobile
            ? 'Note: WHATSAPP_PHONE_NUMBER_ID is set to a 10-digit mobile number (${config.phoneNumberId}). It must be Meta\'s 15-digit Phone Number ID from developers.facebook.com.'
            : 'Please set WHATSAPP_PHONE_NUMBER_ID and WHATSAPP_ACCESS_TOKEN in assets/.env.',
      );
    }

    final toClean = normalizePhone(toPhone);
    final endpoint = Uri.parse('$_graphApiBase/${config.phoneNumberId}/messages');

    final Map<String, dynamic> requestBody = {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': toClean,
      'type': 'text',
      'text': {'body': bodyText},
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer ${config.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final result = _parseMetaResponse(response.statusCode, response.body);

      // Log event
      await _logOutboundEvent(
        toClean: toClean,
        eventType: 'text_message',
        success: result.success,
        statusCode: response.statusCode,
        messageId: result.messageId,
        error: result.errorSummary,
      );

      return result;
    } catch (e) {
      return WhatsAppDispatchResult(
        success: false,
        statusCode: 0,
        errorSummary: 'Network error connecting to Meta Graph API: $e',
        detailedError: e.toString(),
      );
    }
  }

  /// Parse and diagnose Meta Graph API responses
  WhatsAppDispatchResult _parseMetaResponse(int statusCode, String responseBody) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(responseBody) as Map<String, dynamic>?;
    } catch (_) {}

    if (statusCode >= 200 && statusCode < 300 && json != null) {
      final messages = json['messages'] as List?;
      final messageId = (messages != null && messages.isNotEmpty)
          ? messages.first['id']?.toString()
          : null;

      return WhatsAppDispatchResult(
        success: true,
        statusCode: statusCode,
        messageId: messageId,
        rawResponse: json,
      );
    }

    // Diagnose error
    final errorObj = json?['error'] as Map<String, dynamic>?;
    final errorCode = errorObj?['code'] as int? ?? statusCode;
    final errorMessage = errorObj?['message']?.toString() ?? 'Unknown Meta API error';

    String diagnosticMessage = errorMessage;

    if (errorCode == 190) {
      diagnosticMessage = 'Invalid or expired Meta Access Token. Please refresh your Temporary Access Token or generate a Permanent System User Token in Meta Developer Portal.';
    } else if (errorCode == 131030) {
      diagnosticMessage = 'Recipient phone number is not in your Meta Sandbox Allowed List. In Meta Developer Portal > WhatsApp > API Setup > Step 5, click "Manage phone number list" and add the recipient number.';
    } else if (errorCode == 100) {
      diagnosticMessage = 'Invalid Phone Number ID. Ensure WHATSAPP_PHONE_NUMBER_ID is Meta\'s 15-digit ID (e.g. 109284759281928), NOT a 10-digit mobile number.';
    } else if (errorCode == 132000 || errorCode == 132001) {
      diagnosticMessage = 'Template not found or language mismatch. In sandbox, test with template "hello_world" and language "en_US".';
    } else if (errorCode == 131047) {
      diagnosticMessage = 'More than 24 hours have passed since recipient last messaged you. You must send a pre-approved Template message instead of a free text message.';
    }

    return WhatsAppDispatchResult(
      success: false,
      statusCode: statusCode,
      errorSummary: 'Meta Error $errorCode: $diagnosticMessage',
      detailedError: errorObj != null ? jsonEncode(errorObj) : responseBody,
      rawResponse: json,
    );
  }

  /// Log to Supabase message_events and audit_logs
  Future<void> _logOutboundEvent({
    required String toClean,
    required String eventType,
    required bool success,
    required int statusCode,
    String? messageId,
    String? error,
  }) async {
    final maskedPhone = maskPhoneForAudit(toClean);

    final payloadMeta = <String, dynamic>{
      'status_code': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (messageId != null) payloadMeta['message_id'] = messageId;
    if (error != null) payloadMeta['error'] = error;

    try {
      final client = SupabaseService().client;
      if (client != null) {
        await client.from('message_events').insert({
          'channel': 'whatsapp',
          'direction': 'outbound',
          'phone_masked': maskedPhone,
          'event_type': eventType,
          'status': success ? 'sent' : 'failed',
          'payload_meta': payloadMeta,
        });
      }
    } catch (e) {
      debugPrint('Failed to log message event to Supabase: $e');
    }
  }
}
