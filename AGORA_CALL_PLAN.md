# Agora Call Implementation Plan

## Goal

Add real Agora audio/video calling to ChatBox, save every call in the backend, and show real call logs in the Calls tab.

## Call Flow

1. User taps the audio or video button in a chat.
2. Flutter calls backend: `POST /calls`.
3. Backend creates a call record with status `ringing`.
4. Backend returns:
   - `callId`
   - `channelName`
   - `agoraAppId`
   - `agoraToken`
   - `callType`: `audio` or `video`
5. Caller opens `ActiveCallScreen`.
6. Receiver gets websocket event `call:incoming`.
7. Receiver accepts or rejects.
8. Both users join the same Agora channel.
9. When the call ends, Flutter calls `POST /calls/:id/end`.
10. Backend updates the call log with status, end time, and duration.
11. Calls tab loads saved logs from `GET /calls/recent`.

## Backend Plan

Add files:

- `backend/lib/models/call.dart`
- `backend/lib/controllers/call_controller.dart`
- `backend/lib/routes/call_routes.dart`
- `backend/lib/services/agora_token_service.dart`

Update files:

- `backend/lib/routes/app_routes.dart`
- `backend/lib/config/table_registry.dart`
- `backend/pubspec.yaml`
- `backend/.env.example`

## Call Table

Fields:

```text
id
conversationId
channelName
callerId
recipientId
callType        audio | video
status          ringing | accepted | rejected | missed | ended | failed
startedAt
acceptedAt
endedAt
durationSeconds
agoraUidCaller
agoraUidRecipient
recordingUrl
transcript
createdAt
updatedAt
```

## Backend Endpoints

```text
POST /calls
POST /calls/:id/accept
POST /calls/:id/reject
POST /calls/:id/end
GET  /calls/recent
GET  /calls/:id
GET  /calls/:id/token
```

## Websocket Events

```text
call:incoming
call:accepted
call:rejected
call:ended
call:missed
```

The websocket flow should reuse the existing user room pattern from chat:

```text
user:<userId>
```

## Frontend Plan

Add files:

- `frontend/lib/repositry/call_repositry.dart`
- `frontend/lib/provider/call_provider.dart`
- `frontend/lib/screens/home/active_call_screen.dart`
- `frontend/lib/screens/home/incoming_call_screen.dart`

Update files:

- `frontend/lib/model/call_item_model.dart`
- `frontend/lib/screens/home/chat_detail.dart`
- `frontend/lib/screens/home/call.dart`
- `frontend/lib/widget/call_tile_widget.dart`
- `frontend/android/app/src/main/AndroidManifest.xml`
- `frontend/ios/Runner/Info.plist`

## Flutter Dependencies

Already added:

```yaml
agora_rtc_engine
permission_handler
```

## Required Device Permissions

Android:

- `android.permission.INTERNET`
- `android.permission.RECORD_AUDIO`
- `android.permission.CAMERA`
- `android.permission.MODIFY_AUDIO_SETTINGS`
- `android.permission.BLUETOOTH`
- `android.permission.BLUETOOTH_CONNECT`

iOS:

- `NSMicrophoneUsageDescription`
- `NSCameraUsageDescription`

## Saving Call Logs

Calls will be saved in the backend.

Each call should also store `conversationId`, so the call log is connected to the chat thread. This lets the app:

- show call history inside the related conversation later
- open the related chat from a call log
- summarize calls together with the related chat context
- keep one call history across the Calls tab and chat details

When a call starts:

```text
status = ringing
startedAt = now
```

When accepted:

```text
status = accepted
acceptedAt = now
```

When ended:

```text
status = ended
endedAt = now
durationSeconds = endedAt - acceptedAt
```

When rejected:

```text
status = rejected
endedAt = now
```

When not answered:

```text
status = missed
endedAt = now
```

The Calls tab should stop relying only on hardcoded sample data. It should fetch saved call logs from the backend and map them into `CallItemModel`.

## Agora Responsibility

Agora handles:

- Live audio stream.
- Live video stream.
- Joining/leaving RTC channels.
- Remote user audio/video publishing.

Our backend handles:

- Who is calling who.
- Call status.
- Call logs.
- Agora token generation.
- Later recording metadata.
- Later transcript and AI summary.

## Environment Variables

Backend `.env` should contain:

```env
AGORA_APP_ID=...
AGORA_APP_CERTIFICATE=...
```

Never expose `AGORA_APP_CERTIFICATE` in Flutter or client-side code.

## First Build Slice

Build in this order:

1. Backend `Call` model and table registration.
2. Backend `CallRoutes`.
3. Backend `AgoraTokenService` using `.env`.
4. Backend `POST /calls`.
5. Backend `GET /calls/recent`.
6. Flutter `CallRepositry`.
7. Wire chat audio/video buttons to create calls.
8. Add `ActiveCallScreen` and join the Agora channel.
9. Add end-call action and save call log.
10. Replace fake Calls tab list with backend logs.

This gives the app real outgoing calling and saved call logs first.

## Second Build Slice

After outgoing calls work:

1. Emit `call:incoming` websocket event to the receiver.
2. Show `IncomingCallScreen`.
3. Add accept/reject actions.
4. Update caller screen when receiver accepts/rejects.
5. Add missed-call handling when the receiver does not answer.

## Third Build Slice

After basic calling and logs work:

1. Add call recording metadata.
2. Add transcript storage.
3. Add call AI summary endpoint.
4. Show call summaries in call details.
5. Merge call action items into the AI digest.
