import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../shared/di/service_locator.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'API Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: 'Gemini API Key',
                            helperText: 'Enter your Gemini API key',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _obscureApiKey
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureApiKey = !_obscureApiKey;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.save),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          UpdateGeminiApiKey(
                                            _apiKeyController.text,
                                          ),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('API key saved'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          obscureText: _obscureApiKey,
                        ),
                        if (state is SettingsError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
