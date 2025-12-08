import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/resume_entity.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfGeneratorService {
  Future<File> generateResumePdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header with name and contact
          _buildHeader(resume),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // Summary
          if (resume.summary.isNotEmpty) ...[
            _buildSectionTitle('Summary'),
            pw.SizedBox(height: 10),
            pw.Text(resume.summary, textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
          ],

          // Experience
          if (resume.experiences.isNotEmpty) ...[
            _buildSectionTitle('Experience'),
            pw.SizedBox(height: 10),
            ...resume.experiences.map((exp) => _buildExperience(exp)),
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Education'),
            pw.SizedBox(height: 10),
            ...resume.education.map((edu) => _buildEducation(edu)),
          ],

          // Skills
          if (resume.skills.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Skills'),
            pw.SizedBox(height: 10),
            _buildSkills(resume.skills),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Projects'),
            pw.SizedBox(height: 10),
            ...resume.projects.map((proj) => _buildProject(proj)),
          ],
        ],
      ),
    );

    // Save PDF to device
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        '${resume.title}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(Resume resume) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          resume.fullName,
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Text(resume.email),
            pw.SizedBox(width: 20),
            pw.Text(resume.phone),
          ],
        ),
        if (resume.address != null) pw.Text(resume.address!),
        if (resume.linkedIn != null ||
            resume.github != null ||
            resume.website != null)
          pw.Row(
            children: [
              if (resume.linkedIn != null) ...[
                pw.Text('LinkedIn: ${resume.linkedIn}'),
                pw.SizedBox(width: 15),
              ],
              if (resume.github != null) ...[
                pw.Text('GitHub: ${resume.github}'),
                pw.SizedBox(width: 15),
              ],
              if (resume.website != null) pw.Text('Website: ${resume.website}'),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue,
      ),
    );
  }

  pw.Widget _buildExperience(dynamic exp) {
    final dateFormat = DateFormat('MMM yyyy');
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp.position,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${exp.company} | ${dateFormat.format(exp.startDate)} - ${exp.isCurrent ? "Present" : dateFormat.format(exp.endDate!)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 5),
          pw.Text(exp.description),
        ],
      ),
    );
  }

  pw.Widget _buildEducation(dynamic edu) {
    final dateFormat = DateFormat('MMM yyyy');
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree} in ${edu.fieldOfStudy}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${edu.institution} | ${dateFormat.format(edu.startDate)} - ${edu.isCurrent ? "Present" : dateFormat.format(edu.endDate!)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          if (edu.grade != null) pw.Text('Grade: ${edu.grade}'),
        ],
      ),
    );
  }

  pw.Widget _buildSkills(List<dynamic> skills) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 5,
      children: skills
          .map(
            (skill) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue),
                borderRadius: pw.BorderRadius.circular(15),
              ),
              child: pw.Text('${skill.name} (${skill.level})'),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildProject(dynamic proj) {
    final dateFormat = DateFormat('MMM yyyy');
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${dateFormat.format(proj.startDate)} - ${proj.isCurrent ? "Present" : dateFormat.format(proj.endDate!)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          if (proj.url != null) pw.Text('URL: ${proj.url}'),
          pw.SizedBox(height: 5),
          pw.Text(proj.description),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text('Technologies: ${proj.technologies.join(", ")}'),
          ],
        ],
      ),
    );
  }
}
