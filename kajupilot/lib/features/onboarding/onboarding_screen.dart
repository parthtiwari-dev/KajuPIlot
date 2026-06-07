import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/onboarding/onboarding_controller.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/kaju_button_spinner.dart';
import '../../shared/widgets/kaju_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;
  var _saving = false;

  static const _slides = [
    _OnboardingSlideData(
      title: 'Your calls, planned',
      body: 'Every follow-up, promise, and delivery reminder lands on Today.',
      icon: Icons.phone_in_talk_outlined,
    ),
    _OnboardingSlideData(
      title: 'Your money, tracked',
      body: 'Receivables, payables, expenses, and pending balances stay clear.',
      icon: Icons.currency_rupee_outlined,
    ),
    _OnboardingSlideData(
      title: 'Just type. We handle the rest.',
      body: 'Drop a messy trader note and confirm clean tasks, deals, money.',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      key: const Key('onboarding-screen'),
      backgroundColor: colors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KajuSpacing.lg,
            KajuSpacing.xl,
            KajuSpacing.lg,
            KajuSpacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'KajuPilot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : _complete,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    return _OnboardingSlide(data: _slides[index]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < _slides.length; index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: _index == index ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                        horizontal: KajuSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _index == index
                            ? colors.accent
                            : colors.borderMedium,
                        borderRadius: BorderRadius.circular(KajuRadius.full),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: KajuSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('onboarding-continue-button'),
                  onPressed: _saving
                      ? null
                      : isLast
                          ? _complete
                          : _next,
                  icon: _saving
                      ? const KajuButtonSpinner()
                      : Icon(isLast
                          ? Icons.arrow_forward_outlined
                          : Icons.keyboard_arrow_right_outlined),
                  label: Text(isLast ? 'Start setup' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _next() async {
    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) {
      setState(() => _saving = false);
    }
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KajuCard(
                  padding: const EdgeInsets.all(KajuSpacing.xl),
                  child: AspectRatio(
                    aspectRatio: 1.08,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colors.accentMuted,
                              borderRadius:
                                  BorderRadius.circular(KajuRadius.xl),
                            ),
                            child:
                                Icon(data.icon, color: colors.accent, size: 34),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: _MockBusinessPanel(icon: data.icon),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.all(KajuSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.bgSurface,
                              borderRadius:
                                  BorderRadius.circular(KajuRadius.lg),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: colors.success,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: KajuSpacing.xl),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: KajuSpacing.md),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MockBusinessPanel extends StatelessWidget {
  const _MockBusinessPanel({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(KajuSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(KajuRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.accent),
              const SizedBox(width: KajuSpacing.sm),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.textPrimary.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(KajuRadius.full),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KajuSpacing.md),
          for (final width in [132.0, 96.0, 150.0])
            Padding(
              padding: const EdgeInsets.only(bottom: KajuSpacing.sm),
              child: Container(
                width: width,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(KajuRadius.full),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
