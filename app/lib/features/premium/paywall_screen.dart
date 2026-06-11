import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/premium.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Paywall — показва стойността на Premium. До включването на billing-а
/// (чака Play акаунта) CTA-то е „очаквай скоро"; в debug прави mock unlock,
/// за да тестваме premium функциите.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _onCta(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) {
      await premium.activate();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.premiumActive)));
        Navigator.pop(context);
      }
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.premiumComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      (
        icon: Icons.picture_as_pdf_outlined,
        title: l10n.premiumFeaturePdf,
        subtitle: l10n.premiumFeaturePdfDesc,
        soon: false,
      ),
      (
        icon: Icons.palette_outlined,
        title: l10n.premiumFeatureThemes,
        subtitle: null,
        soon: true,
      ),
      (
        icon: Icons.visibility_off_outlined,
        title: l10n.premiumFeatureStealth,
        subtitle: null,
        soon: true,
      ),
      (
        icon: Icons.favorite_outline,
        title: l10n.premiumFeaturePacks,
        subtitle: null,
        soon: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: Text('💜✨', style: TextStyle(fontSize: 48))),
          const SizedBox(height: 12),
          Center(
            child: Text(l10n.premiumTitle,
                style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(l10n.premiumTagline,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),
          for (final f in features) ...[
            Card(
              child: ListTile(
                leading: Icon(f.icon, color: AppColors.accentSoft),
                title: Row(
                  children: [
                    Flexible(child: Text(f.title)),
                    if (f.soon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(l10n.comingSoon,
                            style:
                                Theme.of(context).textTheme.labelMedium),
                      ),
                    ],
                  ],
                ),
                subtitle: f.subtitle == null
                    ? null
                    : Text(f.subtitle!,
                        style: Theme.of(context).textTheme.labelMedium),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 16),
          if (premium.active)
            Center(
              child: Text(l10n.premiumActive,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.accentSoft)),
            )
          else ...[
            FilledButton(
              onPressed: () => _onCta(context),
              child: Text(l10n.premiumCta),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(l10n.premiumTrial,
                  style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
