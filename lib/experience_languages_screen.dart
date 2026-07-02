import 'package:flutter/material.dart';
import 'theme/app_localizations.dart';
import 'theme/bichar_theme_extension.dart';
import 'theme/theme_controller.dart';

class ExperienceLanguagesScreen extends StatelessWidget {
  const ExperienceLanguagesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ExperienceLanguagesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;
    final bichar = context.bichar;

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bichar.drawerBackground,
          appBar: AppBar(
            backgroundColor: bichar.cardBackground,
            title: Text(context.l10n.experienceLanguages),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _SectionHeader(title: 'Language'),
              _SettingTile(
                title: 'Interface Language',
                subtitle: _getLanguageLabel(themeController.locale?.languageCode),
                icon: Icons.language_rounded,
                onTap: () => _showLanguagePicker(context, themeController),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Theme & Appearance'),
              _SettingTile(
                title: 'Theme Mode',
                subtitle: _getThemeModeLabel(themeController.themeMode),
                icon: Icons.palette_outlined,
                onTap: () => _showThemePicker(context, themeController),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accent Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: bichar.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AccentColorPicker(
                      selectedColor: themeController.accentColor,
                      onColorSelected: (color) =>
                          themeController.setAccentColor(color),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              _SectionHeader(title: 'Typography'),
              _SettingTile(
                title: 'Font Family',
                subtitle: themeController.fontFamily,
                icon: Icons.font_download_outlined,
                onTap: () => _showFontPicker(context, themeController),
              ),
              _SettingTile(
                title: 'Text Size',
                subtitle: _getTextSizeLabel(themeController.textScaleFactor),
                icon: Icons.format_size_rounded,
                onTap: () => _showTextSizePicker(context, themeController),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageLabel(String? code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ne':
        return 'Nepali';
      case 'ja':
        return 'Japanese';
      case 'zh':
        return 'Chinese (Simplified)';
      default:
        return 'System Default';
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  String _getTextSizeLabel(double factor) {
    if (factor < 1.0) return 'Small';
    if (factor > 1.0) return 'Large';
    return 'Medium';
  }

  void _showLanguagePicker(BuildContext context, ThemeController controller) {
    _showPicker(
      context: context,
      title: 'Select Language',
      options: [
        _PickerOption(label: 'System Default', value: 'system'),
        _PickerOption(label: 'English', value: 'en'),
        _PickerOption(label: 'Nepali', value: 'ne'),
        _PickerOption(label: 'Japanese', value: 'ja'),
        _PickerOption(label: 'Chinese (Simplified)', value: 'zh'),
      ],
      selectedValue: controller.locale?.languageCode ?? 'system',
      onSelected: (val) => controller.setLanguage(val == 'system' ? null : val),
    );
  }

  void _showThemePicker(BuildContext context, ThemeController controller) {
    _showPicker(
      context: context,
      title: 'Select Theme',
      options: [
        _PickerOption(label: 'System Default', value: ThemeMode.system),
        _PickerOption(label: 'Light Mode', value: ThemeMode.light),
        _PickerOption(label: 'Dark Mode', value: ThemeMode.dark),
      ],
      selectedValue: controller.themeMode,
      onSelected: (val) => controller.setThemeMode(val),
    );
  }

  void _showFontPicker(BuildContext context, ThemeController controller) {
    _showPicker(
      context: context,
      title: 'Select Font',
      options: [
        _PickerOption(label: 'Default', value: 'Default'),
        _PickerOption(label: 'Poppins', value: 'Poppins'),
        _PickerOption(label: 'Roboto', value: 'Roboto'),
        _PickerOption(label: 'Inter', value: 'Inter'),
        _PickerOption(label: 'Nunito', value: 'Nunito'),
        _PickerOption(label: 'Noto Sans', value: 'Noto Sans'),
      ],
      selectedValue: controller.fontFamily,
      onSelected: (val) => controller.setFontFamily(val),
    );
  }

  void _showTextSizePicker(BuildContext context, ThemeController controller) {
    _showPicker(
      context: context,
      title: 'Select Text Size',
      options: [
        _PickerOption(label: 'Small', value: 0.85),
        _PickerOption(label: 'Medium', value: 1.0),
        _PickerOption(label: 'Large', value: 1.2),
      ],
      selectedValue: controller.textScaleFactor,
      onSelected: (val) => controller.setTextScaleFactor(val),
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<_PickerOption<T>> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    final bichar = context.bichar;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: bichar.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt.value == selectedValue;
                return ListTile(
                  title: Text(
                    opt.label,
                    style: TextStyle(
                      color: isSelected ? bichar.accent : bichar.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: bichar.accent)
                      : null,
                  onTap: () {
                    onSelected(opt.value);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: context.bichar.accent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bichar.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: bichar.accent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: bichar.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: bichar.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _PickerOption<T> {
  final String label;
  final T value;
  _PickerOption({required this.label, required this.value});
}

class _AccentColorPicker extends StatelessWidget {
  const _AccentColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  static const List<Color> colors = [
    Color(0xFF6A3DE8), // Purple
    Color(0xFF2196F3), // Blue
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFFFFEB3B), // Yellow
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color.value == selectedColor.value;
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: context.bichar.textPrimary, width: 3)
                    : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
