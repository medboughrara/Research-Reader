import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_reader/features/settings/bloc/settings_bloc.dart';
import 'package:research_reader/shared/services/gemini_service.dart';
import 'package:research_reader/core/errors/app_exceptions.dart'; // For StorageException

// Mock GeminiService
class MockGeminiService extends Mock implements GeminiService {}

void main() {
  group('SettingsBloc', () {
    late MockGeminiService mockGeminiService;

    setUp(() {
      mockGeminiService = MockGeminiService();
    });

    test('initial state is SettingsInitial', () {
      expect(SettingsBloc(geminiService: mockGeminiService).state, SettingsInitial());
    });

    group('LoadSettings Event', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsLoaded(hasGeminiApiKey: true)] when API key exists',
        build: () {
          when(() => mockGeminiService.hasApiKey()).thenAnswer((_) async => true);
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          const SettingsLoaded(hasGeminiApiKey: true),
        ],
        verify: (_) {
          verify(() => mockGeminiService.hasApiKey()).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsLoaded(hasGeminiApiKey: false)] when API key does not exist',
        build: () {
          when(() => mockGeminiService.hasApiKey()).thenAnswer((_) async => false);
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          const SettingsLoaded(hasGeminiApiKey: false),
        ],
        verify: (_) {
          verify(() => mockGeminiService.hasApiKey()).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsError] when hasApiKey throws StorageException',
        build: () {
          when(() => mockGeminiService.hasApiKey()).thenThrow(StorageException("Failed to read from storage"));
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          isA<SettingsError>().having(
            (e) => e.message,
            'message',
            "Could not load API key status. Please ensure the application has storage access and try again.",
          ),
        ],
        verify: (_) {
          verify(() => mockGeminiService.hasApiKey()).called(1);
        },
      );

       blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsError] for general error when hasApiKey throws other Exception',
        build: () {
          when(() => mockGeminiService.hasApiKey()).thenThrow(Exception("Generic failure"));
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          isA<SettingsError>().having(
            (e) => e.message,
            'message',
            "An unexpected error occurred while loading settings. Please restart the app.",
          ),
        ],
      );
    });

    group('UpdateGeminiApiKey Event', () {
      const testApiKey = 'new_test_api_key';
      const emptyApiKey = '';

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsLoaded(hasGeminiApiKey: true)] on successful API key save',
        build: () {
          when(() => mockGeminiService.saveApiKey(any())).thenAnswer((_) async => Future.value());
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(const UpdateGeminiApiKey(testApiKey)),
        expect: () => [
          const SettingsLoaded(hasGeminiApiKey: true),
        ],
        verify: (_) {
          verify(() => mockGeminiService.saveApiKey(testApiKey)).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsError] when saving an empty API key',
        build: () {
          // No need to mock saveApiKey as it shouldn't be called
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(const UpdateGeminiApiKey(emptyApiKey)),
        expect: () => [
          const SettingsError("API key cannot be empty."),
        ],
        verify: (_) {
          verifyNever(() => mockGeminiService.saveApiKey(any()));
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsError] when saveApiKey throws StorageException',
        build: () {
          when(() => mockGeminiService.saveApiKey(any())).thenThrow(StorageException("Failed to write to storage"));
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(const UpdateGeminiApiKey(testApiKey)),
        expect: () => [
          isA<SettingsError>().having(
            (e) => e.message,
            'message',
            "Failed to save API key. Please ensure the application has storage access and try again.",
          ),
        ],
        verify: (_) {
          verify(() => mockGeminiService.saveApiKey(testApiKey)).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsError] for general error when saveApiKey throws other Exception',
        build: () {
          when(() => mockGeminiService.saveApiKey(any())).thenThrow(Exception("Generic save failure"));
          return SettingsBloc(geminiService: mockGeminiService);
        },
        act: (bloc) => bloc.add(const UpdateGeminiApiKey(testApiKey)),
        expect: () => [
          isA<SettingsError>().having(
            (e) => e.message,
            'message',
            "An unexpected error occurred while saving the API key. Please try again.",
          ),
        ],
      );
    });
  });
}
