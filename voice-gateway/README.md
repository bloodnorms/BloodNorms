# BloodNorms Voice Gateway

Google Cloud Run WebSocket gateway connecting Twilio Media Streams to Google Gemini Live API (speech-to-speech) in Telugu, Hindi, and English.

## Key Features
- **No Database / Zero Credentials**: Communicates exclusively via signed requests.
- **Natural Turn-Taking**: Automatic speech-to-speech turn detection and barge-in audio clearing.
- **Automatic Fallback**: Hands off calls to Keypad IVR when daily minute cap (default 60m) is reached or gateway errors occur.
- **Free Allowance**: Deployed on Google Cloud Run in `asia-south1` (Mumbai).

## Deploy to Cloud Run
```bash
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/bloodnorms-voice-gateway
gcloud run deploy bloodnorms-voice-gateway \
  --image gcr.io/YOUR_PROJECT_ID/bloodnorms-voice-gateway \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars GEMINI_API_KEY=YOUR_KEY,VOICE_GATEWAY_SECRET=YOUR_SECRET
```

