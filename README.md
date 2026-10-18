# CivicVote (voting_app)

A Flutter (web, Android) election app backed by Firebase Authentication and Cloud Firestore. Users register, join an election, cast one vote, and see live results.

## Features

- Email/password registration and login (Firebase Auth)
- Elections with candidates, active/closed status and join codes
- One vote per user per election, enforced with a Firestore transaction (`castVote` in `lib/services/firestore_service.dart`) and a deterministic vote document ID (`electionId_userId`) that Firestore rules refuse to overwrite
- Live results with animated vote bars
- Admin screen to create elections and manage voting status

## Tech stack

Flutter, Dart, Provider (state), Firebase Auth, Cloud Firestore.

## Project structure

```text
lib/
  models/      ElectionModel, CandidateModel
  providers/   ElectionProvider
  services/    AuthService, FirestoreService (vote transaction)
  screens/     login, register, home, voting, results, admin, ...
  widgets/     election card, candidate tile, animated vote bar
firestore.rules  Firestore security rules
```

## Run locally

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Create a Firebase project, enable Email/Password auth and Firestore, then run `flutterfire configure` to generate your own `lib/firebase_options.dart`.
3. Deploy the rules in `firestore.rules`.
4. Run:

```bash
flutter pub get
flutter run -d chrome
```

## Known limitations (read before using for a real election)

This is a learning project, not a production voting system.

- **Admin access uses a password checked in the client** (`lib/screens/admin_screen.dart`). Anyone reading the source can find it. A real implementation should use Firebase custom claims and enforce them in the security rules.
- **Firestore rules let any signed-in user create or update elections and candidates**, including vote counters. Writes should be restricted to admins, and counters should be updated only by the vote transaction or a Cloud Function.
- Votes are not anonymous: each vote document stores the voter's user ID.
- There are no automated tests yet.

## Roadmap

- Admin role via custom claims; tighten `firestore.rules`
- Move vote counting into a Cloud Function
- Model and service tests using `fake_cloud_firestore`
