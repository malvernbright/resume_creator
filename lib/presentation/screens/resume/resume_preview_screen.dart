import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../../domain/entities/resume_entity.dart';
import '../../../core/utils/pdf_generator_service.dart';

class ResumePreviewScreen extends StatefulWidget {
  final Resume resume;
  final ResumeTemplate template;

  const ResumePreviewScreen({
    super.key,
    required this.resume,
    required this.template,
  });

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  File? _pdfFile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final pdfService = PdfGeneratorService();
      final file = await pdfService.generateResumePdf(
        widget.resume,
        template: widget.template,
      );

      setState(() {
        _pdfFile = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openInExternalApp() {
    if (_pdfFile != null) {
      OpenFile.open(_pdfFile!.path);
    }
  }

  void _sharePdf() async {
    if (_pdfFile != null) {
      await Share.shareXFiles(
        [XFile(_pdfFile!.path)],
        text: '${widget.resume.fullName} - Resume',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.resume.title}'),
        actions: [
          if (_pdfFile != null) ...[
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open in PDF Viewer',
              onPressed: _openInExternalApp,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: _sharePdf,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating preview...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error generating preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfFile == null) {
      return const Center(child: Text('No preview available'));
    }

    // Show a preview card with resume info and actions
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview info card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resume.fullName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              widget.resume.experiences.isNotEmpty
                                  ? widget.resume.experiences.first.position
                                  : 'Professional',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    'Template',
                    _getTemplateName(widget.template),
                    Icons.palette_outlined,
                  ),
                  _buildInfoRow(
                    'File Location',
                    _pdfFile!.path.split('/').last,
                    Icons.folder_outlined,
                  ),
                  _buildInfoRow(
                    'Email',
                    widget.resume.email,
                    Icons.email_outlined,
                  ),
                  if (widget.resume.phone.isNotEmpty)
                    _buildInfoRow(
                      'Phone',
                      widget.resume.phone,
                      Icons.phone_outlined,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Resume sections summary
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resume Contents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionSummary(
                    'Professional Summary',
                    widget.resume.summary.isNotEmpty ? '✓' : '—',
                  ),
                  _buildSectionSummary(
                    'Experience',
                    '${widget.resume.experiences.length} entries',
                  ),
                  _buildSectionSummary(
                    'Education',
                    '${widget.resume.education.length} entries',
                  ),
                  _buildSectionSummary(
                    'Skills',
                    '${widget.resume.skills.length} skills',
                  ),
                  _buildSectionSummary(
                    'Languages',
                    '${widget.resume.languages.length} languages',
                  ),
                  _buildSectionSummary(
                    'Projects',
                    '${widget.resume.projects.length} projects',
                  ),
                  _buildSectionSummary(
                    'Achievements',
                    '${widget.resume.achievements.length} achievements',
                  ),
                  _buildSectionSummary(
                    'References',
                    widget.resume.references.isEmpty
                        ? 'Not included'
                        : '${widget.resume.references.length} references',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openInExternalApp,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSummary(String section, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(section),
          Text(
            content,
            style: TextStyle(
              color: content == '—' || content == 'Not included'
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTemplateName(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.professional:
        return 'Professional';
      case ResumeTemplate.classic:
        return 'Classic';
      case ResumeTemplate.modern:
        return 'Modern';
      case ResumeTemplate.minimalist:
        return 'Minimalist';
    }
  }
}
