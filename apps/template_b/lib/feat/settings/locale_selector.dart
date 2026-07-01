import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/locale.dart';
import 'package:locale/material_app.dart';
import 'package:locale/translation_registry.dart';

/// Widget that displays a locale selector
/// Shows all available locales and allows the user to change the app language
class LocaleSelector extends BaseStatelessWidget {
  const LocaleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localizationControllerProvider);
    final registry = TranslationRegistry.instance;
    final availableLocales = registry.getRegisteredLocales();
    
    // Get localizations from provider
    final localizations = ref.watch(localizationProvider(context));

    // Map locale codes to display names using current translations
    String getLocaleName(String code) {
      switch (code) {
        case 'en':
          return localizations.getTranslatedString('english');
        case 'es':
          return localizations.getTranslatedString('spanish');
        case 'de':
          return localizations.getTranslatedString('german');
        default:
          return code.toUpperCase();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.getTranslatedString('language'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableLocales.map((localeCode) {
            final isSelected = currentLocale.languageCode == localeCode;
            final displayName = getLocaleName(localeCode);

            return _buildLocaleButton(
              context: context,
              label: displayName,
              localeCode: localeCode,
              isSelected: isSelected,
              onTap: () {
                ref.changeLocale(Locale(localeCode));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocaleButton({
    required BuildContext context,
    required String label,
    required String localeCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              )
            else
              Icon(
                Icons.language,
                color: Colors.grey.shade600,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog version of the locale selector
class LocaleSelectorDialog extends BaseStatelessWidget {
  const LocaleSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localizationControllerProvider);
    final registry = TranslationRegistry.instance;
    final availableLocales = registry.getRegisteredLocales();
    
    // Get localizations from provider
    final localizations = ref.watch(localizationProvider(context));

    // Map locale codes to display names using current translations
    String getLocaleName(String code) {
      switch (code) {
        case 'en':
          return localizations.getTranslatedString('english');
        case 'es':
          return localizations.getTranslatedString('spanish');
        case 'de':
          return localizations.getTranslatedString('german');
        default:
          return code.toUpperCase();
      }
    }

    return AlertDialog(
      title: Text(localizations.getTranslatedString('selectLanguage')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableLocales.map((localeCode) {
          final isSelected = currentLocale.languageCode == localeCode;
          final displayName = getLocaleName(localeCode);

          return ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
            title: Text(displayName),
            selected: isSelected,
            onTap: () {
              ref.changeLocale(Locale(localeCode));
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}

