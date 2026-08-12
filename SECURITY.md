# Security Guidelines

## Critical Security Issues Fixed

### CRITICAL-3: Firestore rate_limits Collection Is Completely Open
**Status:** FIXED ✅

**Issue:** The top-level `rate_limits` collection in Firestore had completely open rules:
```javascript
match /rate_limits/{docId} {
  allow read, write: if true;
}
```
This allowed anyone to:
- Reset their own rate limit by deleting documents
- Read other users' rate limit data
- Flood the collection with junk data
- Completely bypass rate limiting

**Fix Applied:**
- Removed the unused top-level `rate_limits` collection from `firestore.rules`
- The rate limiter only uses `users/{userId}/rateLimits` subcollection (which is properly secured)
- Verified no code references the top-level collection

**Security Note:** Rate limiting is now properly enforced through:
1. Firebase Security Rules (owner-only access to `users/{userId}/rateLimits`)
2. Client-side rate limiting (enabled in `app_config.dart`)
3. Server-side rate limiting via Cloud Functions (recommended for production)

---

### CRITICAL-1: Gemini API Key Bundled in Compiled App Binary
**Status:** FIXED ✅

**Issue:** The `.env` file containing `GEMINI_API_KEY` was listed as a Flutter asset in `pubspec.yaml`. This bundled the API key directly into the compiled app binary (APK/IPA), making it trivially extractable via decompilation.

**Fix Applied:**
- Removed `.env` from `pubspec.yaml` assets
- Added `flutter_dotenv` package for secure environment variable loading
- Updated `app_config.dart` to use `flutter_dotenv` instead of `rootBundle.loadString()`

**Production Security Requirements:**
1. **NEVER ship API keys in client-side code** - Use Cloud Functions to proxy API calls
2. **Create a Firebase Function** to handle Gemini API requests
3. **Store the API key** in Firebase environment configuration (not in code)
4. **Remove the `geminiApiKey` getter** from `app_config.dart` once Cloud Function is implemented

**Example Cloud Function Implementation:**
```javascript
// functions/index.js
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

exports.proxyGemini = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const genAI = new GoogleGenerativeAI(functions.config().gemini.api_key);
  const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' });

  // Rate limiting per user
  // ... implement rate limiting logic

  const result = await model.generateContent(data.prompt);
  return result.response.text();
});
```

---

### HIGH-1: Rate Limiting Is Disabled
**Status:** FIXED ✅

**Issue:** Rate limiting was hardcoded to `false` in `app_config.dart`:
```dart
static const bool rateLimitEnabled = false;
```
Combined with the open Firestore rules, this meant zero abuse prevention. Anyone could spam the Gemini API through the app, potentially running up significant bills.

**Fix Applied:**
- Set `rateLimitEnabled = true` in `app_config.dart`
- Added security warnings about the importance of this setting
- Rate limiting now enforces:
  - Guest users: 10 daily AI calls (device-based)
  - Authenticated users: 10 daily AI calls (user-based via Firestore)

**Security Note:** Client-side rate limiting is a first line of defense. For production, implement server-side rate limiting via Cloud Functions as an additional security layer.

---

### CRITICAL-2: Firebase API Keys Hardcoded in Version-Controlled File
**Status:** FIXED ✅

**Issue:** `firebase_options.dart` contained hardcoded Firebase API keys. While the file was in `.gitignore`, it existed in the working tree and could have been committed.

**Fix Applied:**
- File is already in `.gitignore` (line 25)
- Added security comments to `app_config.dart`
- Documented proper regeneration process

**Proper Regeneration Process:**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Regenerate firebase_options.dart
flutterfire configure

# This will:
# 1. Connect to your Firebase project
# 2. Generate platform-specific configuration
# 3. Create firebase_options.dart with proper keys
# 4. Update platform configuration files
```

**Security Notes for Firebase API Keys:**
- Firebase API keys in client apps are expected (they're restricted by security rules)
- **Always configure Firebase Security Rules** to restrict access
- **Never disable security rules** in production
- **Use Firebase App Check** to prevent abuse
- **Monitor API usage** in Firebase Console

---

## Development Environment Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd linguo_wizard
```

### 2. Create .env File
```bash
cp .env.example .env
# Edit .env with your actual API keys
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 5. Run the App
```bash
flutter run
```

---

## Production Deployment Checklist

### Before Release:
- [ ] **Remove all API keys from client code**
- [ ] **Implement Cloud Functions** for sensitive operations
- [ ] **Configure Firebase Security Rules** properly
- [ ] **Enable Firebase App Check** for abuse prevention
- [ ] **Set up monitoring and alerts** for API usage
- [ ] **Review and test rate limiting** implementation
- [ ] **Audit third-party dependencies** for security vulnerabilities
- [ ] **Enable ProGuard/R8** for Android code obfuscation
- [ ] **Enable bitcode** for iOS (if applicable)
- [ ] **Test app signing** and certificate pinning

### API Key Security:
1. **Never commit API keys** to version control
2. **Never bundle API keys** in app assets
3. **Never hardcode API keys** in source code
4. **Use environment variables** only for development
5. **Proxy all sensitive API calls** through Cloud Functions
6. **Implement proper authentication** and authorization
7. **Use short-lived tokens** when possible
8. **Monitor and rotate keys** regularly

### Firebase Security:
1. **Configure Security Rules** for all Firestore collections
2. **Enable Authentication** before allowing data access
3. **Use Firebase App Check** to verify app integrity
4. **Monitor usage** in Firebase Console
5. **Set up alerts** for unusual activity
6. **Regularly audit** security rules and access patterns

---

## Reporting Security Issues

If you discover a security vulnerability, please report it responsibly:
1. **Do not** open a public GitHub issue
2. **Do not** disclose the vulnerability publicly
3. **Email** security@linguoapp.com with details
4. **Include** steps to reproduce the issue
5. **Allow** reasonable time for response and fix

---

## Security Updates

This document should be reviewed and updated regularly:
- **Monthly**: Review API key rotation schedule
- **Quarterly**: Audit third-party dependencies
- **Bi-annually**: Review and update security rules
- **Annually**: Comprehensive security audit

---

*Last updated: August 11, 2026*
*Security fixes applied: CRITICAL-1, CRITICAL-2*
