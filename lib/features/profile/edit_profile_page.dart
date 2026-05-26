import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/providers/user_provider.dart';
import '../../app/api_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text('Edit Profile', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newName = _nameController.text.trim();
              
              ref.read(userProfileProvider.notifier).updateProfile(
                name: newName,
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
              );

              try {
                final apiService = ref.read(apiServiceProvider);
                await apiService.updateMe(newName);
              } catch (e) {
                print('Error updating profile in database: $e');
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
                context.pop();
              }
            },
            child: Text('Save', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryColor, colorScheme.secondary]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                              : 'U',
                          style: TextStyle(color: colorScheme.onPrimary, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                        ),
                        child: Icon(LucideIcons.camera, color: colorScheme.onPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _EditField(label: 'Full Name', controller: _nameController, icon: LucideIcons.user),
              const SizedBox(height: 20),
              _EditField(label: 'Email Address', controller: _emailController, icon: LucideIcons.mail),
              const SizedBox(height: 20),
              _EditField(label: 'Phone Number', controller: _phoneController, icon: LucideIcons.phone),
              const SizedBox(height: 32),
              Text(
                'Security', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(LucideIcons.lock, color: colorScheme.error, size: 20),
                ),
                title: Text('Change Password', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                subtitle: Text('Last changed 3 months ago', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                trailing: Icon(LucideIcons.chevronRight, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const _EditField({required this.label, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6), 
            fontSize: 12, 
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.4)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}
