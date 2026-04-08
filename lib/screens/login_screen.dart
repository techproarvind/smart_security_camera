import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();

  final _loading  = false.obs;
  final _error    = RxnString();
  final _isSignUp = false.obs;

  bool _obscure        = true;
  bool _obscureConfirm = true;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _email.dispose(); _pass.dispose(); _confirm.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _isSignUp.value = !_isSignUp.value;
    _error.value    = null;
    _animCtrl.forward(from: 0);
  }

  Future<void> _submit() async {
    final email    = _email.text.trim();
    final password = _pass.text;

    if (email.isEmpty || password.isEmpty) {
      _error.value = 'Please fill in all fields.';
      return;
    }

    if (_isSignUp.value) {
      if (password != _confirm.text) {
        _error.value = 'Passwords do not match.';
        return;
      }
      if (password.length < 6) {
        _error.value = 'Password must be at least 6 characters.';
        return;
      }
    }

    _loading.value = true;
    _error.value   = null;

    final err = _isSignUp.value
        ? await AuthController.to.signUp(email, password)
        : await AuthController.to.login(email, password);

    _loading.value = false;

    if (err != null) {
      _error.value = err;
    } else {
      Get.offAllNamed('/role');
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
            const SizedBox(height: 50),

            // Icon + title
            Container(
              width: 72, height: 72,
              margin: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.videocam, color: AppTheme.primary, size: 36),
            ),
            Obx(() => Text(
              _isSignUp.value ? 'Create Account' : 'Welcome back',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textPri, fontSize: 26, fontWeight: FontWeight.w700),
            )),
            const SizedBox(height: 6),
            Obx(() => Text(
              _isSignUp.value ? 'Sign up to start monitoring' : 'Sign in to monitor your cameras',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSec, fontSize: 14),
            )),
            const SizedBox(height: 36),

            // Email
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppTheme.textPri),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSec, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Password
            StatefulBuilder(builder: (_, set) => TextField(
              controller: _pass,
              obscureText: _obscure,
              style: const TextStyle(color: AppTheme.textPri),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSec, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSec, size: 20),
                  onPressed: () => set(() => _obscure = !_obscure),
                ),
              ),
            )),

            // Confirm password (sign up only)
            Obx(() => _isSignUp.value
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: StatefulBuilder(builder: (_, set) => TextField(
                      controller: _confirm,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: AppTheme.textPri),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSec, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSec, size: 20),
                          onPressed: () => set(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    )),
                  )
                : const SizedBox.shrink()),

            // Error
            Obx(() => _error.value != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error.value!, style: const TextStyle(color: AppTheme.danger, fontSize: 13))),
                      ]),
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 24),

            // Submit button
            Obx(() => ElevatedButton(
              onPressed: _loading.value ? null : _submit,
              child: _loading.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg))
                  : Text(_isSignUp.value ? 'Create Account' : 'Sign In'),
            )),

            const SizedBox(height: 14),

            // Toggle login/signup
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Obx(() => Text(
                _isSignUp.value ? 'Already have an account? ' : "Don't have an account? ",
                style: const TextStyle(color: AppTheme.textSec, fontSize: 13),
              )),
              GestureDetector(
                onTap: _toggleMode,
                child: Obx(() => Text(
                  _isSignUp.value ? 'Sign In' : 'Sign Up',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                )),
              ),
            ]),

            // Forgot password (login only)
            Obx(() => !_isSignUp.value
                ? TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            GlassCard(
              child: Column(children: const [
                Text('Demo credentials', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                SizedBox(height: 4),
                Text('admin@smartcam.app  /  123456',
                    style: TextStyle(color: AppTheme.textPri, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Enter Email', 'Type your email above then tap Forgot Password',
          backgroundColor: AppTheme.surface, colorText: AppTheme.textPri,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final err = await AuthController.to.forgotPassword(email);
    if (err == null) {
      Get.snackbar('Email Sent', 'Password reset email sent to $email',
          backgroundColor: AppTheme.surface, colorText: AppTheme.primary,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', err,
          backgroundColor: AppTheme.surface, colorText: AppTheme.danger,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
