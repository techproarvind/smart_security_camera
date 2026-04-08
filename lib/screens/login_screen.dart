import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/provider/auth_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<AuthProvider>().login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => _error = 'Invalid email or password.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.videocam, color: AppTheme.primary, size: 52),
            const SizedBox(height: 16),
            const Text('Welcome back', textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textPri, fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Sign in to monitor your cameras', textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
            const SizedBox(height: 40),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppTheme.textPri),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSec, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              obscureText: _obscure,
              style: const TextStyle(color: AppTheme.textPri),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSec, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSec, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg))
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot password?', style: TextStyle(color: AppTheme.primary)),
            ),
            const SizedBox(height: 40),
            GlassCard(
              child: Column(
                children: [
                  const Text('Demo credentials', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('admin@smartcam.app  /  1234', style: TextStyle(color: AppTheme.textPri, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}