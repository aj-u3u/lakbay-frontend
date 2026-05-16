import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final signupShowPasswordProvider = StateProvider.autoDispose<bool>((ref) => false);

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordsMatch = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      _isPasswordsMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final showPassword = ref.watch(signupShowPasswordProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/login'),
                icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join Lakbay+ and start exploring',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Juan Dela Cruz',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'your.email@example.com',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !showPassword,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Create a strong password',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              onPressed: () {
                                ref.read(signupShowPasswordProvider.notifier).state = !showPassword;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !showPassword,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            errorText: !_isPasswordsMatch && _confirmPasswordController.text.isNotEmpty
                                ? 'Passwords do not match'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isPasswordsMatch && 
                                      _passwordController.text.isNotEmpty && 
                                      _confirmPasswordController.text.isNotEmpty
                                ? _handleSignup
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
