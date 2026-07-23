/// Firestore seed script for curated scenarios.
///
/// Upload all scenarios from [seed_list.json] to the Firestore /scenarios collection.
///
/// ## Prerequisites
/// 1. A Firebase project with Firestore enabled
/// 2. Firebase Admin SDK credentials (service account JSON)
/// 3. Set GOOGLE_APPLICATION_CREDENTIALS env var pointing to your service account file
///
/// ## Usage
/// ```bash
/// # Option 1: Firebase Console (recommended for simplicity)
/// 1. Go to Firebase Console > Firestore > your project
/// 2. Click "Start collection" > id: "scenarios"
/// 3. For each scenario in seed_list.json:
///    - Click "Add document"
///    - Set document ID to the scenario's `id` field
///    - Copy all fields from the JSON entry
/// 4. Repeat for all 34 scenarios
///
/// # Option 2: Firebase Console JSON Import
/// 1. Go to Firestore > Data tab
/// 2. Click the three-dot menu > "Import JSON"
/// 3. You'll need to transform seed_list.json into Firestore's
///    import format (each scenario as a separate document)
///
/// # Option 3: This Dart script (requires dart_firebase_admin or manual setup)
/// Run: dart run scripts/seed_scenarios.dart
/// ```
///
/// Note: This file documents the upload process. The actual upload
/// is typically done via Firebase Console for one-time seeding.
/// For production, consider a CI/CD pipeline using Firebase Admin SDK.
void main() {
  print('Firestore seed script for /scenarios collection');
  print('See comments above for upload instructions.');
  print('');
  print('Source file: assets/data/scenarios/seed_list.json');
  print('Target collection: /scenarios');
  print('Access: public read, admin-only write');
}
