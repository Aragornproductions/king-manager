import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/crypto_utils.dart';
import 'locker_vault_screen.dart';

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hasPin = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final has = await LockerAuth.hasPin();
    setState(() {
      _hasPin = has;
      _loading = false;
    });
  }

  Future<void> _tryBiometric() async {
    final auth = LocalAuthentication();
    try {
      final canCheck = await auth.canCheckBiometrics;
      if (!canCheck) return;
      final ok = await auth.authenticate(
        localizedReason: 'Unlock your King Manager Locker',
      );
      if (ok && mounted) _enterVault();
    } catch (_) {
      // Biometric unavailable — user can still use PIN.
    }
  }

  void _enterVault() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LockerVaultScreen()),
    );
  }

  Future<void> _submitCreate() async {
    if (_pinController.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }
    if (_pinController.text != _confirmController.text) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    await LockerAuth.setPin(_pinController.text);
    setState(() {
      _hasPin = true;
      _error = null;
    });
    _enterVault();
  }

  Future<void> _submitVerify() async {
    final ok = await LockerAuth.verifyPin(_pinController.text);
    if (ok) {
      _enterVault();
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Locker')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Icon(Icons.lock_rounded, size: 72, color: theme.colorScheme.tertiary),
              ),
              const SizedBox(height: 16),
              Text(
                _hasPin ? 'Enter your PIN' : 'Create a Locker PIN',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(labelText: 'PIN', counterText: ''),
              ),
              if (!_hasPin) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(labelText: 'Confirm PIN', counterText: ''),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasPin ? _submitVerify : _submitCreate,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(_hasPin ? 'Unlock' : 'Create Locker'),
                ),
              ),
              if (_hasPin) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use biometrics instead'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
