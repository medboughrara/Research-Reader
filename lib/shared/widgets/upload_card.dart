import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

class UploadCard extends StatefulWidget {
  final void Function(List<String> files)? onFilesSelected;
  final bool isDragActive;

  const UploadCard({
    super.key,
    this.onFilesSelected,
    this.isDragActive = false,
  });

  @override
  State<UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<UploadCard> {
  bool _isDragging = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      widget.onFilesSelected?.call(result.files.map((f) => f.path!).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(LucideIcons.upload, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Upload Research Papers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Drag and drop PDF files or click to browse',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            DragTarget<List<String>>(
              onWillAccept: (data) {
                setState(() => _isDragging = true);
                return data != null;
              },
              onAccept: (List<String> files) {
                setState(() => _isDragging = false);
                widget.onFilesSelected?.call(files);
              },
              onLeave: (data) {
                setState(() => _isDragging = false);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isDragging ? Theme.of(context).primaryColor : Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    color: _isDragging ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.fileText,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Drop your research papers here',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'or',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickFiles,
                          child: const Text('Browse Files'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
