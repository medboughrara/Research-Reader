# Research Reader

A powerful Flutter application that helps researchers analyze academic papers using AI. The app integrates with Google's Gemini AI for text analysis and NVIDIA's Text-to-Speech API for audio summaries.

## Features

- 📄 PDF Document Upload & Management
- 🤖 AI-Powered Paper Analysis:
  - Paper Summarization
  - Methodology Analysis
  - Statistical Analysis
  - Citation Extraction
  - Future Research Suggestions
- 🗣️ Text-to-Speech Capabilities
- 🔒 Secure API Key Management
- 📱 Cross-Platform Support (iOS, Android, Web)

## Architecture

The app follows Clean Architecture principles and is organized into the following structure:

```
lib/
├── core/          # Core functionality, configurations, and utilities
├── features/      # Feature-based modules
├── shared/        # Shared components and services
└── main.dart      # Application entry point
```

### Key Technologies

- **Flutter**: UI Framework
- **Bloc**: State Management
- **Dio**: HTTP Client
- **Retrofit**: Type-safe API Client
- **Hive**: Local Storage
- **Flutter Secure Storage**: Secure Key Storage
- **Google Gemini API**: AI Text Analysis
- **NVIDIA TTS API**: Text-to-Speech

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Google Gemini API Key
- NVIDIA TTS API Key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/[your-username]/research_reader.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up your API keys:
   - Create a `.env` file in the project root
   - Add your API keys:
     ```
     GEMINI_API_KEY=your_key_here
     TTS_API_KEY=your_key_here
     ```

4. Run the app:
   ```bash
   flutter run
   ```

### Development Environment

The app supports separate development and production environments. To run in development mode:

```bash
flutter run --dart-define=FLUTTER_ENV=development
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Google Gemini API for AI capabilities
- NVIDIA TTS API for speech synthesis
- Flutter team for the amazing framework

## Contact

For any queries or suggestions, please open an issue in the repository.
