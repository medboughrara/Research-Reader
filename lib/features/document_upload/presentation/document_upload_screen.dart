import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/document_upload_bloc.dart';
import '../../../shared/models/document.dart'; 
import '../../../shared/di/service_locator.dart'; 
import '../../../shared/services/document_service.dart'; 
import '../../analysis/presentation/analysis_screen.dart'; // Added import for AnalysisScreen

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentUploadBloc(documentService: getIt<DocumentService>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Document'),
        ),
        body: BlocConsumer<DocumentUploadBloc, DocumentUploadState>(
          listener: (context, state) {
            if (state is DocumentUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document uploaded successfully! Navigating to analysis...')),
              );
              // Navigate to analysis screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisScreen(document: state.document),
                ),
              );
            } else if (state is DocumentUploadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload Failed: ${state.error}')), // Displaying user-friendly error
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is DocumentUploadInProgress)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload your research paper',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Supported format: PDF',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Prevent multiple upload requests if one is already in progress
                            if (state is! DocumentUploadInProgress) {
                                context.read<DocumentUploadBloc>().add(
                                      DocumentSelectionRequested(),
                                    );
                            }
                          },
                          child: const Text('Select Document'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
