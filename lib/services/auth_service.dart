import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

typedef ExistingAccountConfirmation = Future<bool> Function();

class AuthUpgradeResult {
  const AuthUpgradeResult({
    this.credential,
    required this.signedIntoExistingAccount,
    this.redirectStarted = false,
    this.alreadySignedIn = false,
    this.cancelledByUser = false,
  });

  final UserCredential? credential;
  final bool signedIntoExistingAccount;
  final bool redirectStarted;
  final bool alreadySignedIn;
  final bool cancelledByUser;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleInitialized = false;

  /// OAuth scope required for two-way Google Calendar sync.
  static const String calendarScope =
      'https://www.googleapis.com/auth/calendar.events';

  String? _calendarAccessToken;
  String? get calendarAccessToken => _calendarAccessToken;

  /// Requests the Google Calendar OAuth scope and returns an access token that
  /// can be used against the Calendar REST API. Returns null if unavailable.
  ///
  /// NOTE: the Google Cloud project must have the Google Calendar API enabled
  /// and the OAuth consent screen configured (with the signing-in user added
  /// as a test user) for this to succeed.
  Future<String?> requestCalendarAccess() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope(calendarScope);
        final result = await _auth.signInWithPopup(provider);
        final oauth = result.credential as OAuthCredential?;
        _calendarAccessToken = oauth?.accessToken;
        return _calendarAccessToken;
      }

      await _ensureGoogleInitializedForNative();
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>[calendarScope],
      );
      final authorization =
          await account.authorizationClient.authorizeScopes(
        const <String>[calendarScope],
      );
      _calendarAccessToken = authorization.accessToken;
      return _calendarAccessToken;
    } catch (error) {
      debugPrint('requestCalendarAccess failed: $error');
      return null;
    }
  }

  Future<AuthUpgradeResult> signInOrUpgradeWithGoogle() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      return upgradeAnonymousToGoogle();
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _signInWithPopupOrRedirect(
        provider,
        signedIntoExistingAccount: false,
      );
    }

    final googleCredential = await _getGoogleCredentialForNative();
    final signedIn = await _auth.signInWithCredential(googleCredential);
    return AuthUpgradeResult(
      credential: signedIn,
      signedIntoExistingAccount: false,
    );
  }

  Future<AuthUpgradeResult> upgradeAnonymousToGoogle({
    ExistingAccountConfirmation? onExistingAccountConfirm,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No active session found. Please sign in first.',
      );
    }
    if (!user.isAnonymous) {
      return const AuthUpgradeResult(
        signedIntoExistingAccount: false,
        alreadySignedIn: true,
      );
    }

    final shouldContinue = onExistingAccountConfirm == null
        ? true
        : await _confirmExistingAccountSwitch(onExistingAccountConfirm);
    if (!shouldContinue) {
      return const AuthUpgradeResult(
        signedIntoExistingAccount: false,
        cancelledByUser: true,
      );
    }

    // No merge path: discard guest auth state and sign in with Google.
    await _auth.signOut();

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _signInWithPopupOrRedirect(
        provider,
        signedIntoExistingAccount: true,
      );
    }

    final googleCredential = await _getGoogleCredentialForNative();
    final signedIn = await _auth.signInWithCredential(googleCredential);
    return AuthUpgradeResult(
      credential: signedIn,
      signedIntoExistingAccount: true,
    );
  }

  Future<AuthUpgradeResult> upgradeToGoogle({
    ExistingAccountConfirmation? onExistingAccountConfirm,
  }) {
    return upgradeAnonymousToGoogle(
      onExistingAccountConfirm: onExistingAccountConfirm,
    );
  }

  Future<void> handleRedirectResult() async {
    if (!kIsWeb) return;

    try {
      final result = await _auth.getRedirectResult();
      if (result.credential != null) {
        debugPrint(
          'Google redirect auth completed for uid=${result.user?.uid ?? _auth.currentUser?.uid}',
        );
      }
    } catch (error) {
      debugPrint('Ignoring redirect result error: $error');
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _ensureGoogleInitializedForNative();
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Best effort sign-out for Google SDK.
      }
    }

    await _auth.signOut();
  }

  Future<User?> continueAsGuest() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      return currentUser;
    }
    final credential = await _auth.signInAnonymously();
    return credential.user;
  }

  Future<AuthCredential> _getGoogleCredentialForNative() async {
    await _ensureGoogleInitializedForNative();
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const <String>['email'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google sign-in returned no ID token.',
      );
    }

    return GoogleAuthProvider.credential(
      idToken: idToken,
    );
  }

  Future<void> _ensureGoogleInitializedForNative() async {
    if (_googleInitialized || kIsWeb) {
      return;
    }
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  bool _isPopupBlockedError(String code) {
    return code == 'popup-blocked' || code == 'popup-closed-by-user';
  }

  Future<bool> _confirmExistingAccountSwitch(
    ExistingAccountConfirmation? onExistingAccountConfirm,
  ) async {
    if (onExistingAccountConfirm == null) {
      return false;
    }
    try {
      return await onExistingAccountConfirm();
    } catch (_) {
      return false;
    }
  }

  Future<AuthUpgradeResult> _signInWithPopupOrRedirect(
    GoogleAuthProvider provider, {
    required bool signedIntoExistingAccount,
  }) async {
    try {
      final signedIn = await _auth.signInWithPopup(provider);
      return AuthUpgradeResult(
        credential: signedIn,
        signedIntoExistingAccount: signedIntoExistingAccount,
      );
    } on FirebaseAuthException catch (error) {
      if (_isPopupBlockedError(error.code)) {
        await _auth.signInWithRedirect(provider);
        return AuthUpgradeResult(
          signedIntoExistingAccount: signedIntoExistingAccount,
          redirectStarted: true,
        );
      }
      rethrow;
    }
  }
}
