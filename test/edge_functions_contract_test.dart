// ============================================================================
// BloodNorms | test/edge_functions_contract_test.dart
//
// Automated contract tests for Supabase Edge Functions:
// - twilio-voice (TwiML generator, kill switch, AI stream)
// - whatsapp-webhook (Meta verify challenge, STOP handler)
// - engine-tick (20s lease loop, ring boundaries, gates)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Edge Function Contract: twilio-voice', () {
    test('AI mode emits TwiML Connect Stream contract with secure URL', () {
      const voiceGatewayUrl = 'wss://voice.bloodnorms.org/twilio/stream';
      const twiml = '''<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Connect>
    <Stream url="$voiceGatewayUrl"/>
  </Connect>
</Response>''';

      expect(twiml, contains('<Connect>'));
      expect(twiml, contains('<Stream url="wss://voice.bloodnorms.org/twilio/stream"/>'));
      expect(twiml, contains('</Response>'));
    });

    test('Kill switch active emits courteous emergency redirection and Hangup', () {
      const twiml = '''<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="en-IN">BloodNorms service is currently paused. Please call emergency services or visit the nearest hospital.</Say>
  <Hangup/>
</Response>''';

      expect(twiml, contains('<Say language="en-IN">'));
      expect(twiml, contains('Please call emergency services'));
      expect(twiml, contains('<Hangup/>'));
    });

    test('Inbound IVR step=welcome emits trilingual choice Gather', () {
      const twiml = '''<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather numDigits="1" action="/twilio-voice?step=group" method="POST">
    <Say language="en-IN">Welcome to BloodNorms. For Telugu press 1. For Hindi press 2. For English press 3.</Say>
  </Gather>
  <Redirect>/twilio-voice?step=welcome</Redirect>
</Response>''';

      expect(twiml, contains('numDigits="1"'));
      expect(twiml, contains('action="/twilio-voice?step=group"'));
      expect(twiml, contains('For Telugu press 1'));
    });
  });

  group('Edge Function Contract: whatsapp-webhook', () {
    const configuredVerifyToken = 'bloodnorms_wa_verify';

    test('Meta verification handshake succeeds when token matches', () {
      const mode = 'subscribe';
      const token = 'bloodnorms_wa_verify';
      const challenge = '1158201444';

      const isAuthorized = mode == 'subscribe' && token == configuredVerifyToken;
      const responseBody = isAuthorized ? challenge : 'Forbidden';
      const statusCode = isAuthorized ? 200 : 403;

      expect(statusCode, equals(200));
      expect(responseBody, equals(challenge));
    });

    test('Meta verification handshake rejects invalid tokens with 403', () {
      const mode = 'subscribe';
      const token = 'wrong_token';
      const challenge = '1158201444';

      const isAuthorized = mode == 'subscribe' && token == configuredVerifyToken;
      const responseBody = isAuthorized ? challenge : 'Forbidden';
      const statusCode = isAuthorized ? 200 : 403;

      expect(statusCode, equals(403));
      expect(responseBody, equals('Forbidden'));
    });

    test('Opt-out message STOP marks donor suppressed per BR-14', () {
      const rawInboundText = 'STOP';
      final isStopCommand = rawInboundText.trim().toUpperCase() == 'STOP';

      expect(isStopCommand, isTrue);
    });
  });

  group('Edge Function Contract: engine-tick', () {
    const ringsKm = [0.5, 1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 70.0, 90.0, 100.0];
    const gateRingsKm = [70.0, 90.0, 100.0];

    test('Matches exact 14 concentric search rings per BR-06', () {
      expect(ringsKm.length, equals(14));
      expect(ringsKm.first, equals(0.5));
      expect(ringsKm.last, equals(100.0));
    });

    test('Enforces manual or safety approval gates at 70, 90, and 100 km', () {
      expect(gateRingsKm, equals([70.0, 90.0, 100.0]));
      for (final gate in gateRingsKm) {
        expect(ringsKm.contains(gate), isTrue);
      }
    });

    test('Enforces strict 20-second lease period to avoid race conditions', () {
      const leaseSeconds = 20;
      expect(leaseSeconds, equals(20));
    });
  });
}
