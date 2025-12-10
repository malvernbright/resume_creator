import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/resume_entity.dart';
import '../../domain/entities/common_entities.dart';
import 'package:path_provider/path_provider.dart';

enum ResumeTemplate { classic, modern, professional, minimalist }

class PdfGeneratorService {
  // Primary purple color matching the app theme
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF9C5BAF);
  static const PdfColor darkColor = PdfColor.fromInt(0xFF7B4896);
  static const PdfColor lightGray = PdfColor.fromInt(0xFF666666);
  static const PdfColor black = PdfColors.black;

  Future<File> generateResumePdf(
    Resume resume, {
    ResumeTemplate template = ResumeTemplate.professional,
  }) async {
    switch (template) {
      case ResumeTemplate.professional:
        return _generateProfessionalPdf(resume);
      case ResumeTemplate.classic:
        return _generateClassicPdf(resume);
      case ResumeTemplate.modern:
        return _generateModernPdf(resume);
      case ResumeTemplate.minimalist:
        return _generateMinimalistPdf(resume);
    }
  }

  // Generate PDF as bytes for preview
  Future<Uint8List> generateResumePdfData(
    Resume resume, {
    ResumeTemplate template = ResumeTemplate.professional,
  }) async {
    final file = await generateResumePdf(resume, template: template);
    return file.readAsBytes();
  }

  // ==================== PROFESSIONAL TEMPLATE (like your CV) ====================
  Future<File> _generateProfessionalPdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header with name and title
          _buildProfessionalHeader(resume),
          pw.SizedBox(height: 8),

          // Contact information line
          _buildProfessionalContactLine(resume),
          pw.SizedBox(height: 5),

          // Links (GitHub, LinkedIn, etc.)
          _buildProfessionalLinks(resume),
          pw.SizedBox(height: 20),

          // Professional Summary
          if (resume.summary.isNotEmpty) ...[
            _buildProfessionalSectionTitle('PROFESSIONAL SUMMARY'),
            pw.SizedBox(height: 8),
            pw.Text(
              resume.summary,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),
          ],

          // Technical Skills
          if (resume.skills.isNotEmpty) ...[
            _buildProfessionalSectionTitle('TECHNICAL SKILLS'),
            pw.SizedBox(height: 8),
            _buildProfessionalSkills(resume.skills),
            pw.SizedBox(height: 20),
          ],

          // Professional Experience & Key Projects
          if (resume.experiences.isNotEmpty || resume.projects.isNotEmpty) ...[
            _buildProfessionalSectionTitle(
              'PROFESSIONAL EXPERIENCE & KEY PROJECTS',
            ),
            pw.SizedBox(height: 8),
            ...resume.experiences.map(
              (exp) => _buildProfessionalExperience(exp),
            ),
            if (resume.projects.isNotEmpty) ...[
              ...resume.projects.map((proj) => _buildProfessionalProject(proj)),
            ],
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildProfessionalSectionTitle('EDUCATION'),
            pw.SizedBox(height: 8),
            ...resume.education.map((edu) => _buildProfessionalEducation(edu)),
          ],

          // Achievements
          if (resume.achievements.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildProfessionalSectionTitle('ACHIEVEMENTS & CERTIFICATIONS'),
            pw.SizedBox(height: 8),
            ...resume.achievements.map(
              (ach) => _buildProfessionalAchievement(ach),
            ),
          ],

          // Languages
          if (resume.languages.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildProfessionalSectionTitle('LANGUAGES'),
            pw.SizedBox(height: 8),
            _buildProfessionalLanguages(resume.languages),
          ],

          // References (Optional)
          if (resume.references.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildProfessionalSectionTitle('REFERENCES'),
            pw.SizedBox(height: 8),
            ...resume.references.map((ref) => _buildProfessionalReference(ref)),
          ],
        ],
      ),
    );

    return _savePdf(pdf, resume.title);
  }

  pw.Widget _buildProfessionalHeader(Resume resume) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          resume.fullName,
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: black,
          ),
        ),
        if (resume.experiences.isNotEmpty)
          pw.Text(
            resume.experiences.first.position,
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: lightGray,
            ),
          ),
      ],
    );
  }

  pw.Widget _buildProfessionalContactLine(Resume resume) {
    final List<String> contactParts = [];
    if (resume.address != null && resume.address!.isNotEmpty) {
      contactParts.add(resume.address!);
    }
    contactParts.add(resume.phone);
    contactParts.add(resume.email);

    return pw.Text(
      contactParts.join(' | '),
      style: const pw.TextStyle(fontSize: 10, color: lightGray),
    );
  }

  pw.Widget _buildProfessionalLinks(Resume resume) {
    final List<pw.Widget> links = [];

    if (resume.linkedIn != null && resume.linkedIn!.isNotEmpty) {
      links.add(
        pw.UrlLink(
          destination: resume.linkedIn!.startsWith('http')
              ? resume.linkedIn!
              : 'https://${resume.linkedIn}',
          child: pw.Text(
            resume.linkedIn!,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    if (resume.github != null && resume.github!.isNotEmpty) {
      links.add(
        pw.UrlLink(
          destination: resume.github!.startsWith('http')
              ? resume.github!
              : 'https://${resume.github}',
          child: pw.Text(
            resume.github!,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    if (resume.website != null && resume.website!.isNotEmpty) {
      links.add(
        pw.UrlLink(
          destination: resume.website!.startsWith('http')
              ? resume.website!
              : 'https://${resume.website}',
          child: pw.Text(
            resume.website!,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    if (links.isEmpty) return pw.SizedBox.shrink();

    return pw.Wrap(spacing: 15, children: links);
  }

  pw.Widget _buildProfessionalSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: black,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 2),
          height: 1,
          width: double.infinity,
          color: primaryColor,
        ),
      ],
    );
  }

  pw.Widget _buildProfessionalSkills(List<Skill> skills) {
    // Group skills by category
    final Map<String, List<Skill>> groupedSkills = {};
    for (var skill in skills) {
      final category = skill.category ?? 'General';
      groupedSkills.putIfAbsent(category, () => []);
      groupedSkills[category]!.add(skill);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: groupedSkills.entries.map((entry) {
        final skillNames = entry.value.map((s) => s.name).join(', ');
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '• ${entry.key}: ',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.TextSpan(
                  text: skillNames,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildProfessionalExperience(Experience exp) {
    final dateFormat = DateFormat('MMM yyyy');
    final dateRange =
        '${dateFormat.format(exp.startDate)} - ${exp.isCurrent ? "Present" : dateFormat.format(exp.endDate!)}';

    // Parse description into bullet points if it contains newlines or bullet markers
    final List<String> bulletPoints = _parseDescriptionToBullets(
      exp.description,
    );

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${exp.position} | ${exp.company}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            dateRange,
            style: pw.TextStyle(
              fontSize: 9,
              color: lightGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          ...bulletPoints.map(
            (point) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      point.trim(),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProfessionalProject(Project proj) {
    final dateFormat = DateFormat('MMM yyyy');
    final dateRange =
        '${dateFormat.format(proj.startDate)} - ${proj.isCurrent ? "Present" : dateFormat.format(proj.endDate!)}';

    final List<String> bulletPoints = _parseDescriptionToBullets(
      proj.description,
    );

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            dateRange,
            style: pw.TextStyle(
              fontSize: 9,
              color: lightGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          ...bulletPoints.map(
            (point) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      point.trim(),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (proj.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10),
              child: pw.Text(
                'Technologies: ${proj.technologies.join(", ")}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                  color: lightGray,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildProfessionalEducation(Education edu) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree} in ${edu.fieldOfStudy}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${edu.institution}, ${edu.endDate?.year ?? "Present"}',
            style: const pw.TextStyle(fontSize: 10, color: lightGray),
          ),
          if (edu.grade != null && edu.grade!.isNotEmpty)
            pw.Text(
              'Grade: ${edu.grade}',
              style: const pw.TextStyle(fontSize: 9, color: lightGray),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildProfessionalAchievement(Achievement ach) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '${ach.title}: ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.TextSpan(
                    text: ach.description,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (ach.organization != null)
                    pw.TextSpan(
                      text: ' (${ach.organization})',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProfessionalLanguages(List<Language> languages) {
    return pw.Wrap(
      spacing: 20,
      runSpacing: 4,
      children: languages
          .map(
            (lang) => pw.Text(
              '${lang.name} (${lang.proficiency})',
              style: const pw.TextStyle(fontSize: 10),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildProfessionalReference(Reference ref) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            ref.name,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${ref.position}, ${ref.company}',
            style: const pw.TextStyle(fontSize: 10, color: lightGray),
          ),
          pw.Text(
            'Email: ${ref.email} | Phone: ${ref.phone}',
            style: const pw.TextStyle(fontSize: 9, color: lightGray),
          ),
        ],
      ),
    );
  }

  List<String> _parseDescriptionToBullets(String description) {
    // Split by newlines, bullet points, or numbered lists
    final lines = description.split(RegExp(r'\n|(?=•)|(?=\d+\.)'));
    return lines
        .map((line) => line.replaceAll(RegExp(r'^[•\-\*\d+\.]+\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // ==================== CLASSIC TEMPLATE ====================
  Future<File> _generateClassicPdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(resume),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 20),

          if (resume.summary.isNotEmpty) ...[
            _buildSectionTitle('Summary'),
            pw.SizedBox(height: 10),
            pw.Text(resume.summary, textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
          ],

          if (resume.experiences.isNotEmpty) ...[
            _buildSectionTitle('Experience'),
            pw.SizedBox(height: 10),
            ...resume.experiences.map((exp) => _buildExperience(exp)),
          ],

          if (resume.education.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Education'),
            pw.SizedBox(height: 10),
            ...resume.education.map((edu) => _buildEducation(edu)),
          ],

          if (resume.skills.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Skills'),
            pw.SizedBox(height: 10),
            _buildSkills(resume.skills),
          ],

          if (resume.projects.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('Projects'),
            pw.SizedBox(height: 10),
            ...resume.projects.map((proj) => _buildProject(proj)),
          ],

          if (resume.references.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSectionTitle('References'),
            pw.SizedBox(height: 10),
            ...resume.references.map((ref) => _buildProfessionalReference(ref)),
          ],
        ],
      ),
    );

    return _savePdf(pdf, resume.title);
  }

  // ==================== MODERN TEMPLATE ====================
  Future<File> _generateModernPdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          // Modern header with colored background
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.fullName,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${resume.email} • ${resume.phone}',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.white,
                  ),
                ),
                if (resume.address != null)
                  pw.Text(
                    resume.address!,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          if (resume.summary.isNotEmpty) ...[
            _buildModernSectionTitle('About Me'),
            pw.SizedBox(height: 8),
            pw.Text(resume.summary, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 20),
          ],

          if (resume.experiences.isNotEmpty) ...[
            _buildModernSectionTitle('Experience'),
            pw.SizedBox(height: 8),
            ...resume.experiences.map((exp) => _buildExperience(exp)),
          ],

          if (resume.education.isNotEmpty) ...[
            _buildModernSectionTitle('Education'),
            pw.SizedBox(height: 8),
            ...resume.education.map((edu) => _buildEducation(edu)),
          ],

          if (resume.skills.isNotEmpty) ...[
            _buildModernSectionTitle('Skills'),
            pw.SizedBox(height: 8),
            _buildSkills(resume.skills),
          ],

          if (resume.references.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildModernSectionTitle('References'),
            pw.SizedBox(height: 8),
            ...resume.references.map((ref) => _buildProfessionalReference(ref)),
          ],
        ],
      ),
    );

    return _savePdf(pdf, resume.title);
  }

  pw.Widget _buildModernSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: darkColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // ==================== MINIMALIST TEMPLATE ====================
  Future<File> _generateMinimalistPdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              resume.fullName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              '${resume.email} • ${resume.phone}',
              style: const pw.TextStyle(fontSize: 10, color: lightGray),
            ),
          ),
          pw.SizedBox(height: 30),

          if (resume.summary.isNotEmpty) ...[
            pw.Text(
              resume.summary,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 30),
          ],

          if (resume.experiences.isNotEmpty) ...[
            _buildMinimalistSectionTitle('Experience'),
            ...resume.experiences.map((exp) => _buildExperience(exp)),
          ],

          if (resume.education.isNotEmpty) ...[
            _buildMinimalistSectionTitle('Education'),
            ...resume.education.map((edu) => _buildEducation(edu)),
          ],

          if (resume.skills.isNotEmpty) ...[
            _buildMinimalistSectionTitle('Skills'),
            pw.Text(
              resume.skills.map((s) => s.name).join(' • '),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],

          if (resume.references.isNotEmpty) ...[
            _buildMinimalistSectionTitle('References'),
            ...resume.references.map((ref) => _buildProfessionalReference(ref)),
          ],
        ],
      ),
    );

    return _savePdf(pdf, resume.title);
  }

  pw.Widget _buildMinimalistSectionTitle(String title) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 20),
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ==================== SHARED WIDGETS ====================
  Future<File> _savePdf(pw.Document pdf, String title) async {
    final output = await getApplicationDocumentsDirectory();
    final fileName = '${title}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
