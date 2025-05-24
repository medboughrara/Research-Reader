import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/nvidia_tts_service.dart';
import '../../../shared/di/service_locator.dart';
import '../bloc/tts_settings_bloc.dart';

class TtsOptionsScreen extends StatelessWidget {
  const TtsOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TtsSettingsBloc(
        getIt<NvidiaTtsService>(),
        getIt<SharedPreferences>(),
      )..add(LoadTtsSettings()),
      child: const TtsOptionsView(),
    );
  }
}

class TtsOptionsView extends StatelessWidget {
  const TtsOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Options'),
      ),
      body: BlocBuilder<TtsSettingsBloc, TtsSettingsState>(
        builder: (context, state) {
          if (state is TtsSettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TtsSettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TtsSettingsBloc>().add(LoadTtsSettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TtsSettingsLoaded) {
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
                          'Voice Selection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'female',
                              label: Text('Female'),
                              icon: Icon(LucideIcons.user),
                            ),
                            ButtonSegment(
                              value: 'male',
                              label: Text('Male'),
                              icon: Icon(LucideIcons.user),
                            ),
                          ],
                          selected: {state.gender},
                          onSelectionChanged: (selection) {
                            context.read<TtsSettingsBloc>().add(
                              UpdateVoiceSettings(
                                gender: selection.first,
                                emotion: 'neutral', // Reset emotion when changing gender
                                speakingRate: state.speakingRate,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Emotion'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: NvidiaTtsService.availableVoices[state.gender]!
                              .keys
                              .map((emotion) => ChoiceChip(
                                    label: Text(emotion.toUpperCase()),
                                    selected: state.emotion == emotion,
                                    onSelected: (selected) {
                                      if (selected) {
                                        context.read<TtsSettingsBloc>().add(
                                          UpdateVoiceSettings(
                                            gender: state.gender,
                                            emotion: emotion,
                                            speakingRate: state.speakingRate,
                                          ),
                                        );
                                      }
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Speaking Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: state.speakingRate,
                          min: 0.5,
                          max: 2.0,
                          divisions: 30,
                          label: state.speakingRate.toStringAsFixed(2),
                          onChanged: (value) {
                            context.read<TtsSettingsBloc>().add(
                              UpdateVoiceSettings(
                                gender: state.gender,
                                emotion: state.emotion,
                                speakingRate: value,
                              ),
                            );
                          },
                        ),
                        Center(
                          child: Text(
                            '${state.speakingRate.toStringAsFixed(2)}x',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.isTesting
                      ? null
                      : () {
                          context.read<TtsSettingsBloc>().add(
                                TestVoiceSettings(
                                  gender: state.gender,
                                  emotion: state.emotion,
                                  speakingRate: state.speakingRate,
                                ),
                              );
                        },
                  icon: state.isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(LucideIcons.play),
                  label: Text(state.isTesting ? 'Testing...' : 'Test Voice'),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
