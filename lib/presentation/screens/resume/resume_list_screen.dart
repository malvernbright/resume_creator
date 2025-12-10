import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../../domain/entities/resume_entity.dart';
import '../../../core/utils/pdf_generator_service.dart';
import '../../../core/utils/word_export_service.dart';
import '../../bloc/resume/resume_bloc.dart';
import '../../bloc/resume/resume_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'create_resume_screen.dart';

class ResumeListScreen extends StatelessWidget {
  final List<Resume> resumes;

  const ResumeListScreen({super.key, required this.resumes});

  void _handleExportPdf(BuildContext context, Resume resume) async {
    // Show template selection dialog
    final template = await _showTemplateSelectionDialog(context);
    if (template == null) return;

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

      final pdfService = PdfGeneratorService();
      final file = await pdfService.generateResumePdf(
        resume,
        template: template,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF generated successfully!'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );

      // Also offer to share
      await Share.shareXFiles([XFile(file.path)], text: 'My Resume');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }

  Future<ResumeTemplate?> _showTemplateSelectionDialog(
    BuildContext context,
  ) async {
    return showDialog<ResumeTemplate>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TemplateOption(
              title: 'Professional',
              description: 'Clean layout with sections like your CV',
              icon: Icons.work_outline,
              onTap: () => Navigator.pop(context, ResumeTemplate.professional),
            ),
            _TemplateOption(
              title: 'Classic',
              description: 'Traditional resume format',
              icon: Icons.description_outlined,
              onTap: () => Navigator.pop(context, ResumeTemplate.classic),
            ),
            _TemplateOption(
              title: 'Modern',
              description: 'Colorful header with purple theme',
              icon: Icons.palette_outlined,
              onTap: () => Navigator.pop(context, ResumeTemplate.modern),
            ),
            _TemplateOption(
              title: 'Minimalist',
              description: 'Simple and elegant design',
              icon: Icons.remove_circle_outline,
              onTap: () => Navigator.pop(context, ResumeTemplate.minimalist),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleExportWord(BuildContext context, Resume resume) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating Word document...')),
      );

      final wordService = WordExportService();
      final file = await wordService.generateResumeWord(resume);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Word document generated successfully!'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );

      // Also offer to share
      await Share.shareXFiles([XFile(file.path)], text: 'My Resume');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating Word document: $e')),
      );
    }
  }

  void _handlePreview(BuildContext context, Resume resume) async {
    // Show template selection dialog
    final template = await _showTemplateSelectionDialog(context);
    if (template == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfPreviewScreen(resume: resume, template: template),
      ),
    );
  }

  void _handleDelete(BuildContext context, Resume resume) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete "${resume.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ResumeBloc>().add(DeleteResume(resume.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Resume deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleEdit(BuildContext context, Resume resume) {
    // Capture bloc references before navigation
    final resumeBloc = context.read<ResumeBloc>();
    final authBloc = context.read<AuthBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: resumeBloc,
          child: CreateResumeScreen(resume: resume),
        ),
      ),
    ).then((_) {
      // Reload resumes after editing using captured references
      if (authBloc.state is Authenticated) {
        resumeBloc.add(LoadResumes((authBloc.state as Authenticated).user.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resumes.length,
      itemBuilder: (context, index) {
        final resume = resumes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.description)),
            title: Text(resume.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(resume.fullName),
                Text(
                  'Updated: ${DateFormat('MMM dd, yyyy').format(resume.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _handleEdit(context, resume);
                } else if (value == 'preview') {
                  _handlePreview(context, resume);
                } else if (value == 'pdf') {
                  _handleExportPdf(context, resume);
                } else if (value == 'word') {
                  _handleExportWord(context, resume);
                } else if (value == 'delete') {
                  _handleDelete(context, resume);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('Preview CV'),
                    ],
                  ),
                ),
                const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
                const PopupMenuItem(value: 'word', child: Text('Export Word')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            onTap: () => _handleEdit(context, resume),
          ),
        );
      },
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// PDF Preview Screen with interactive controls
class _PdfPreviewScreen extends StatelessWidget {
  final Resume resume;
  final ResumeTemplate template;

  const _PdfPreviewScreen({required this.resume, required this.template});

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfGeneratorService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${resume.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: () async {
              try {
                final file = await pdfService.generateResumePdf(
                  resume,
                  template: template,
                );
                await Share.shareXFiles([XFile(file.path)], text: 'My Resume');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sharing PDF: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Save PDF',
            onPressed: () async {
              try {
                final file = await pdfService.generateResumePdf(
                  resume,
                  template: template,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF saved to: ${file.path}'),
                      action: SnackBarAction(
                        label: 'Open',
                        onPressed: () => OpenFile.open(file.path),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving PDF: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print',
            onPressed: () async {
              try {
                final pdfData = await pdfService.generateResumePdfData(
                  resume,
                  template: template,
                );
                await Printing.layoutPdf(onLayout: (_) async => pdfData);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error printing: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) =>
            pdfService.generateResumePdfData(resume, template: template),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '${resume.title.replaceAll(' ', '_')}_CV.pdf',
      ),
    );
  }
}
