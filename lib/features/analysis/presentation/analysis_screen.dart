import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/analysis_bloc.dart';
import '../../../shared/models/document.dart';

class AnalysisScreen extends StatelessWidget {
  final Document document;

  const AnalysisScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalysisBloc(context.read())..add(StartAnalysis(document)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Analysis'),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.download),
              onPressed: () {
                // TODO: Implement export functionality
              },
            ),
          ],
        ),
        body: BlocBuilder<AnalysisBloc, AnalysisState>(
          builder: (context, state) {
            if (state is AnalysisInProgress) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing document...'),
                  ],
                ),
              );
            }

            if (state is AnalysisFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Analysis failed: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AnalysisBloc>().add(StartAnalysis(document));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is AnalysisSuccess) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Summary',
                      icon: LucideIcons.clipboardList,
                      content: state.document.summary ?? 'No summary available',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Methodology',
                      icon: LucideIcons.graduationCap,
                      content: 'Methodology details will be shown here',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Statistical Significance',
                      icon: LucideIcons.barChart2,
                      content: 'Statistical findings will be shown here',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Future Research',
                      icon: LucideIcons.lightbulb,
                      content: 'Future research suggestions will be shown here',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Citations',
                      icon: LucideIcons.quote,
                      content: 'Citations will be shown here',
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Start analysis to see results'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(content),
          ],
        ),
      ),
    );
  }
}
