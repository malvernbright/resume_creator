import 'package:flutter/material.dart';
import '../../../domain/entities/resume_entity.dart';
import 'package:intl/intl.dart';

class ResumeListScreen extends StatelessWidget {
  final List<Resume> resumes;

  const ResumeListScreen({super.key, required this.resumes});

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
                  // Navigate to edit screen
                } else if (value == 'pdf') {
                  // Generate PDF
                } else if (value == 'delete') {
                  // Delete resume
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
            onTap: () {
              // Navigate to resume detail screen
            },
          ),
        );
      },
    );
  }
}
