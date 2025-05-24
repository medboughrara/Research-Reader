import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../../shared/di/service_locator.dart';
import '../../../shared/services/gemini_service.dart'; // Added import
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
  void initState() {
    super.initState();
    // It might be good to load the initial state of the API key if available
    // For example, by dispatching an event to SettingsBloc or directly from GeminiService
    // For now, we'll rely on the BlocBuilder to reflect current state after LoadSettings.
    // Potentially, prefill _apiKeyController.text if a key is already stored.
    // context.read<SettingsBloc>().add(LoadSettings()); // Dispatch LoadSettings if not done automatically
    
    // To prefill the text field, we need to access the current key.
    // This could be done by listening to the SettingsLoaded state or by having a method in GeminiService.
    // For simplicity, let's assume the user types it in or it's loaded by an initial event.
    // If you want to pre-fill, you'd do something like:
    // final geminiService = getIt<GeminiService>();
    // geminiService.getApiKey().then((key) {
    //   if (key != null && mounted) {
    //     _apiKeyController.text = key;
    //   }
    // });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(geminiService: getIt<GeminiService>()) // Modified BlocProvider
        ..add(LoadSettings()), // Dispatch LoadSettings on creation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>( // Changed to BlocConsumer
          listener: (context, state) {
            if (state is SettingsLoaded && state.hasGeminiApiKey) {
              // Optionally prefill if the key is now loaded and wasn't before
              // This might conflict if user is typing, handle with care
              // For now, just ensure UI reflects 'hasApiKey' state.
            }
          },
          builder: (context, state) {
            // If a key is loaded and present, you might want to show it (obscured)
            // This example doesn't explicitly prefill the TextField from SettingsLoaded state
            // but it's a common pattern.
            
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
                        Text(
                          state is SettingsLoaded && state.hasGeminiApiKey 
                              ? 'Gemini API Key is set.' 
                              : 'Gemini API Key is not set.',
                          style: TextStyle(
                            color: state is SettingsLoaded && state.hasGeminiApiKey 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: 'Enter or Update Gemini API Key',
                            helperText: 'Your API key will be stored securely.',
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
                                    // Clear field after attempting to save, or on success
                                    // _apiKeyController.clear(); 
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('API key save attempt initiated.'),
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
