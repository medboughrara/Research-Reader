import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Unused import from previous analysis
import 'package:lucide_icons/lucide_icons.dart';
import 'package:research_reader/shared/widgets/upload_card.dart';
import 'package:research_reader/shared/widgets/research_paper_card.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/shared/di/service_locator.dart';
import 'package:research_reader/shared/services/document_service.dart';
import 'package:research_reader/core/utils/logger.dart';
import '../../../core/errors/app_exceptions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDragActive = false;
  bool showOfflineOnly = false;
  String selectedVoice = 'en-US-Neural2-F';
  double playbackSpeed = 1.0;
  String? currentPlayingId;

  final List<Map<String, String>> voiceOptions = [
    {'id': 'en-US-Neural2-F', 'name': 'Emma (Female)'},
    {'id': 'en-US-Neural2-M', 'name': 'James (Male)'},
    {'id': 'en-GB-Neural2-F', 'name': 'Sophie (British Female)'},
    {'id': 'en-GB-Neural2-M', 'name': 'William (British Male)'},
    {'id': 'en-AU-Neural2-F', 'name': 'Olivia (Australian Female)'},
  ];

  // late StreamSubscription<List<Document>> _documentSubscription; // Commented out
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() async {
    // It's good practice to capture the BuildContext and check mounted status
    // before the async operation if you plan to use context after it.
    if (!mounted) return; 
    final currentContext = context; // Capture context

    try {
      final documents = await getIt<DocumentService>().getAllDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
        });
      }
    } catch (e, s) {
       AppLogger.logError("Failed to load documents", error: e, stackTrace: s, tag: "HomeScreen");
       if (mounted) { // Check mounted again before using captured context
         ScaffoldMessenger.of(currentContext).showSnackBar( // Use captured context
           SnackBar(content: Text('Failed to load documents: ${e is AppException ? e.message : e.toString()}'))
         );
       }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleFilesSelected(List<String> files) {
    // TODO: Implement file upload
    AppLogger.logInfo('Files selected: $files', tag: "HomeScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: const Text('Research Reader'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.speaker),
            onPressed: () => Navigator.pushNamed(context, '/tts-options'),
            tooltip: 'TTS Options',
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (rest of the UI as before, no changes needed here for this specific lint)
            const Center(
              child: Column(
                children: [
                  Text(
                    'Research Paper Analyzer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload your research papers and get detailed analysis and insights',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            UploadCard(
              isDragActive: isDragActive,
              onFilesSelected: _handleFilesSelected,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploaded Papers (${_documents.length})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: showOfflineOnly,
                          onChanged: (value) {
                            if (mounted) { 
                              setState(() {
                                showOfflineOnly = value!;
                              });
                            }
                          },
                        ),
                        const Text('Show offline papers only'),
                      ],
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.filter),
                      label: const Text('Filter'),
                      onPressed: () {
                        // TODO: Implement filtering
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_documents.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.bookOpen,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No papers uploaded yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your first research paper to get started',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final document = _documents[index];
                  return ResearchPaperCard(
                    document: document,
                    isPlaying: currentPlayingId == document.id,
                    isCached: false, // TODO: Implement offline caching status
                    onPlay: () {
                       if (mounted) { 
                        setState(() {
                          if (currentPlayingId == document.id) {
                            currentPlayingId = null;
                          } else {
                            currentPlayingId = document.id;
                          }
                        });
                       }
                    },
                    onDelete: () async {
                      // Capture context before async gap for ScaffoldMessenger
                      if (!mounted) return;
                      final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture

                      try {
                        await getIt<DocumentService>().deleteDocument(document.id);
                        _loadDocuments(); // Refresh list
                      } catch (e, s) {
                        AppLogger.logError("Failed to delete document ${document.id}", error: e, stackTrace: s, tag: "HomeScreen");
                        // Use captured ScaffoldMessenger, guarded by mounted check (though it's less critical here as it's captured from a mounted state)
                        if (mounted) { 
                          scaffoldMessenger.showSnackBar(
                             SnackBar(content: Text('Failed to delete document: ${e is AppException ? e.message : e.toString()}'))
                          );
                        }
                      }
                    },
                    onDownload: () {
                      // TODO: Implement download
                    },
                    onOfflineToggle: () {
                      // TODO: Implement offline toggling
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
