import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../main.dart'; // For themeModeProvider

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'JD',
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Juan Dela Cruz',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                      ),
                                      Text(
                                        'juan.delacruz@email.com',
                                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => context.push('/profile/edit'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                                ),
                                child: Text('Edit Profile', style: TextStyle(color: colorScheme.onSurface)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Your Travel Stats',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Adventures',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                              ),
                              const Text(
                                '12',
                                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Text('🗺️', style: TextStyle(fontSize: 32))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(label: 'Places', value: '8'),
                            _StatItem(label: 'Districts', value: '3/5'),
                            _StatItem(label: 'Groups', value: '4'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                const _SectionHeader(icon: LucideIcons.settings, title: 'Settings'),
                const SizedBox(height: 12),
                
                _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Push, email, SMS',
                      onTap: () => context.push('/profile/settings/notifications'),
                    ),
                    _SettingsItem(
                      icon: LucideIcons.mapPin,
                      title: 'Default Region',
                      subtitle: 'Davao Region',
                      onTap: () => context.push('/profile/settings/region'),
                    ),
                    _SettingsItem(
                      icon: LucideIcons.palette,
                      title: 'Appearance',
                      subtitle: themeMode == ThemeMode.system ? 'System default' : (themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
                      onTap: () => _showAppearanceModal(context, ref),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Text('Account & Privacy', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: LucideIcons.lock,
                      title: 'Privacy & Security',
                      subtitle: 'Password, data, permissions',
                      onTap: () => context.push('/profile/settings/privacy'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Text('Support', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: LucideIcons.info,
                      title: 'Help Center',
                      subtitle: 'FAQs and support',
                      onTap: () => context.push('/profile/settings/help'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                      foregroundColor: colorScheme.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.logOut, size: 20),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text('Lakbay+ v1.0.0', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12)),
                      Text('Made with ❤️ for Davao Region', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppearanceModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AppearanceModal(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (idx < items.length - 1)
                Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _AppearanceModal extends ConsumerWidget {
  const _AppearanceModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Appearance', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
          ),
          const SizedBox(height: 24),
          _ThemeOption(
            title: 'Light Mode',
            subtitle: 'Bright and clear',
            icon: LucideIcons.sun,
            iconColor: Colors.amber,
            isSelected: currentTheme == ThemeMode.light,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.light;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            title: 'Dark Mode',
            subtitle: 'Easy on the eyes',
            icon: LucideIcons.moon,
            iconColor: Colors.blue,
            isSelected: currentTheme == ThemeMode.dark,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            title: 'System Default',
            subtitle: 'Follows device settings',
            icon: LucideIcons.monitor,
            iconColor: Colors.blueGrey,
            isSelected: currentTheme == ThemeMode.system,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.system;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
