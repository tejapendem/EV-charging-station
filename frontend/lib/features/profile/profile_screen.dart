import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ev_connect_india/providers/auth_provider.dart';
import 'package:ev_connect_india/providers/theme_provider.dart';
import 'package:ev_connect_india/config/app_config.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null
                      ? Icon(Icons.person, size: 48, color: colorScheme.onPrimaryContainer)
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: colorScheme.surface, width: 2)),
                    child: Icon(Icons.camera_alt, size: 16, color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'User Name', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (user?.email != null) Text(user!.email!, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            if (user?.phoneNumber != null) Text(user!.phoneNumber!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            _ProfileMenuCard(
              children: [
                _ProfileMenuItem(icon: Icons.edit_outlined, title: 'Edit Profile', onTap: () {}, colorScheme: colorScheme),
                _ProfileMenuItem(icon: Icons.car_crash_outlined, title: 'My Vehicles', subtitle: '2 vehicles registered', onTap: () {}, colorScheme: colorScheme),
              ],
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              title: 'Preferences',
              children: [
                SwitchListTile(
                  secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: colorScheme.primary),
                  title: const Text('Dark Mode'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (v) => ref.read(themeProvider.notifier).toggleTheme(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.language, color: colorScheme.primary),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProfileMenuCard(
              title: 'Support',
              children: [
                _ProfileMenuItem(icon: Icons.info_outline, title: 'About', subtitle: 'Version ${AppConfig.appVersion}', onTap: () {}, colorScheme: colorScheme),
                _ProfileMenuItem(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}, colorScheme: colorScheme),
                _ProfileMenuItem(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}, colorScheme: colorScheme),
                _ProfileMenuItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}, colorScheme: colorScheme),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutConfirmation(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('EV Connect India v${AppConfig.appVersion}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout, size: 48),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _ProfileMenuCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(title!, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ProfileMenuItem({required this.icon, required this.title, this.subtitle, required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
