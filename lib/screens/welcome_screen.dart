import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _continueWithGoogle() async {
    if (_isLoading) return;
    final provider = context.read<CalendarProvider>();
    if (provider.isGuestUiLoggedOut) {
      final shouldContinue = await _confirmGuestDiscardWarning();
      if (!shouldContinue) {
        return;
      }
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AuthService.instance.signInOrUpgradeWithGoogle();
      if (result.redirectStarted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).redirectingToGoogle)),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            AppLocalizations.of(context).googleSignInFailed(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _confirmGuestDiscardWarning() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).guestDiscardWarningTitle),
        content: Text(AppLocalizations.of(context).guestDiscardWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).continueLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _continueAsGuest() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<CalendarProvider>().continueAsGuest();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            AppLocalizations.of(context).guestSignInFailed(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.calendar_month, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    l10n.welcomeTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _continueWithGoogle,
                    child: Text(l10n.continueWithGoogle),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _continueAsGuest,
                    child: Text(l10n.continueAsGuest),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
