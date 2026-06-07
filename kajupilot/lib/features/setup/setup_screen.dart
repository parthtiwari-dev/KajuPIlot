import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import '../../shared/widgets/kaju_button_spinner.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _setupCodeController = TextEditingController();
  final _nameController = TextEditingController(text: 'Owner');

  @override
  void dispose() {
    _setupCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colors = context.kajuColors;

    return Scaffold(
      key: const Key('setup-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KajuSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.accentMuted,
                          borderRadius: BorderRadius.circular(KajuRadius.lg),
                        ),
                        child: Icon(Icons.store_outlined, color: colors.accent),
                      ),
                    ),
                    const SizedBox(height: KajuSpacing.lg),
                    Text('KajuPilot',
                        style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: KajuSpacing.sm),
                    Text(
                      'Private setup',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: KajuSpacing.xl),
                    TextFormField(
                      key: const Key('setup-code-field'),
                      controller: _setupCodeController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Setup code',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 4) {
                          return 'Enter the setup code.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: KajuSpacing.md),
                    TextFormField(
                      key: const Key('owner-name-field'),
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    if (authState.hasError) ...[
                      const SizedBox(height: KajuSpacing.md),
                      Text(
                        'Setup failed. Check the code and backend connection.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.danger,
                            ),
                      ),
                    ],
                    const SizedBox(height: KajuSpacing.lg),
                    FilledButton(
                      key: const Key('setup-submit-button'),
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const KajuButtonSpinner()
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(authControllerProvider.notifier).setupOwner(
          setupCode: _setupCodeController.text.trim(),
          name: _nameController.text.trim(),
        );
  }
}
