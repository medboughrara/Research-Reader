import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:research_reader/shared/widgets/upload_card.dart';
import 'package:research_reader/shared/widgets/research_paper_card.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/shared/di/service_locator.dart';
import 'package:research_reader/shared/services/document_service.dart';

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

  late StreamSubscription<List<Document>> _documentSubscription;
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() async {
    final documents = await getIt<DocumentService>().getAllDocuments();
    setState(() {
      _documents = documents;
    });
  }

  @override
  void dispose() {
    _documentSubscription.cancel();
    super.dispose();
  }

  void _handleFilesSelected(List<String> files) {
    // TODO: Implement file upload
    print('Files selected: $files');
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
                            setState(() {
                              showOfflineOnly = value!;
                            });
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
                      setState(() {
                        if (currentPlayingId == document.id) {
                          currentPlayingId = null;
                        } else {
                          currentPlayingId = document.id;
                        }
                      });
                    },
                    onDelete: () async {
                      await getIt<DocumentService>().deleteDocument(document.id);
                      _loadDocuments();
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
