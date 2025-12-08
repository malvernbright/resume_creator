import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/resume_entity.dart';
import '../../../core/utils/pdf_generator_service.dart';
import '../../../core/utils/word_export_service.dart';
import '../../bloc/resume/resume_bloc.dart';
import '../../bloc/resume/resume_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'create_resume_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class ResumeListScreen extends StatelessWidget {
  final List<Resume> resumes;

  const ResumeListScreen({super.key, required this.resumes});

  void _handleExportPdf(BuildContext context, Resume resume) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

      final pdfService = PdfGeneratorService();
      final file = await pdfService.generateResumePdf(resume);

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ResumeBloc>(),
          child: CreateResumeScreen(resume: resume),
        ),
      ),
    ).then((_) {
      // Reload resumes after editing
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state is Authenticated) {
        context.read<ResumeBloc>().add(
          LoadResumes((authBloc.state as Authenticated).user.id),
        );
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
