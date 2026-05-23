import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/services/ai_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildSectionHeader('Appearance', textColor),
          _buildCardStyleContainer(
            cardColor,
            Column(
              children: [
                _buildSwitchTile(
                  title: 'Night Mode',
                  subtitle: 'Use dark theme across the app',
                  icon: PhosphorIconsDuotone.moon,
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    notifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  accentColor: settings.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildSectionHeader('App Preferences', textColor),
          _buildCardStyleContainer(
            cardColor,
            Column(
              children: [
                _buildSwitchTile(
                  title: 'Auto-Sort on Upload',
                  subtitle: 'Automatically organize new documents',
                  icon: PhosphorIconsDuotone.magicWand,
                  value: settings.autoSortOnUpload,
                  onChanged: (val) {
                    notifier.setAutoSortOnUpload(val);
                  },
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  accentColor: settings.accentColor,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Show AI Summary',
                  subtitle: 'Display AI generated summaries for docs',
                  icon: PhosphorIconsDuotone.sparkle,
                  value: settings.showAiSummary,
                  onChanged: (val) {
                    notifier.setShowAiSummary(val);
                  },
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  accentColor: settings.accentColor,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Auto-Delete Duplicates',
                  subtitle: 'Remove duplicate files to save space',
                  icon: PhosphorIconsDuotone.copy,
                  value: settings.autoDeleteDuplicates,
                  onChanged: (val) {
                    notifier.setAutoDeleteDuplicates(val);
                  },
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  accentColor: settings.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildSectionHeader('AI Configuration', textColor),
          _buildCardStyleContainer(
            cardColor,
            Column(
              children: [
                _buildListTile(
                  title: 'Gemini API Key',
                  trailingText: 'Configure',
                  icon: PhosphorIconsDuotone.key,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _showApiKeyDialog(textColor, secondaryTextColor, isDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildSectionHeader('About & Support', textColor),
          _buildCardStyleContainer(
            cardColor,
            Column(
              children: [
                _buildListTile(
                  title: 'Help Menu',
                  icon: PhosphorIconsDuotone.question,
                  textColor: textColor,
                  onTap: () {
                    // Show Help Dialog or navigate
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help section coming soon!')),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  title: 'App Version',
                  trailingText: 'v1.0.0 (Build 34)',
                  icon: PhosphorIconsDuotone.info,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: color.withOpacity(0.6),
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardStyleContainer(Color color, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 56);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color secondaryTextColor,
    required Color accentColor,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: accentColor,
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor)),
      secondary: Icon(icon, color: textColor.withOpacity(0.8), size: 28),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    );
  }

  Widget _buildListTile({
    required String title,
    String? trailingText,
    required IconData icon,
    required Color textColor,
    Color? secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor.withOpacity(0.8), size: 28),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w500)),
      trailing: trailingText != null
          ? Text(trailingText, style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor))
          : Icon(PhosphorIconsDuotone.caretRight, color: textColor.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    );
  }

  Future<void> _showApiKeyDialog(Color textColor, Color secondaryTextColor, bool isDark) async {
    final currentKey = await AiService.getApiKey();
    _apiKeyController.text = currentKey ?? '';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          title: Text(
            'Gemini API Key',
            style: AppTextStyles.titleLarge.copyWith(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your Google Gemini API key to enable AI-powered document classification and summaries.',
                style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: AppTextStyles.bodyLarge.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Paste key here...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.bodyLarge.copyWith(color: secondaryTextColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = _apiKeyController.text.trim();
                await AiService.saveApiKey(key);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.defaultAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Key'),
            ),
          ],
        );
      },
    );
  }
}
