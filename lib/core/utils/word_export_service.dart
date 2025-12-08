import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../../domain/entities/resume_entity.dart';
import 'package:intl/intl.dart';

class WordExportService {
  Future<File> generateResumeWord(Resume resume) async {
    // Create a new Excel workbook (can be opened in Word/Excel/Sheets)
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Set column width for better formatting
    sheet.getRangeByIndex(1, 1, 1, 3).columnWidth = 30;

    int currentRow = 1;

    // Header - Name
    sheet.getRangeByIndex(currentRow, 1).setText(resume.fullName);
    sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 24;
    sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
    currentRow += 2;

    // Contact Information
    sheet.getRangeByIndex(currentRow, 1).setText('Email: ${resume.email}');
    currentRow++;
    sheet.getRangeByIndex(currentRow, 1).setText('Phone: ${resume.phone}');
    currentRow++;

    if (resume.address != null) {
      sheet
          .getRangeByIndex(currentRow, 1)
          .setText('Address: ${resume.address}');
      currentRow++;
    }

    if (resume.linkedIn != null) {
      sheet
          .getRangeByIndex(currentRow, 1)
          .setText('LinkedIn: ${resume.linkedIn}');
      currentRow++;
    }

    if (resume.github != null) {
      sheet.getRangeByIndex(currentRow, 1).setText('GitHub: ${resume.github}');
      currentRow++;
    }

    if (resume.website != null) {
      sheet
          .getRangeByIndex(currentRow, 1)
          .setText('Website: ${resume.website}');
      currentRow++;
    }

    currentRow++;

    // Professional Summary
    if (resume.summary.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('PROFESSIONAL SUMMARY');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;
      sheet.getRangeByIndex(currentRow, 1).setText(resume.summary);
      sheet.getRangeByIndex(currentRow, 1).cellStyle.wrapText = true;
      currentRow += 2;
    }

    // Experience
    if (resume.experiences.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('EXPERIENCE');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;

      for (var exp in resume.experiences) {
        sheet.getRangeByIndex(currentRow, 1).setText(exp.position);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
        currentRow++;

        sheet
            .getRangeByIndex(currentRow, 1)
            .setText(
              '${exp.company} | ${_formatDate(exp.startDate)} - ${exp.endDate != null ? _formatDate(exp.endDate!) : 'Present'}',
            );
        currentRow++;

        sheet.getRangeByIndex(currentRow, 1).setText(exp.description);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.wrapText = true;
        currentRow += 2;
      }
    }

    // Education
    if (resume.education.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('EDUCATION');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;

      for (var edu in resume.education) {
        sheet.getRangeByIndex(currentRow, 1).setText(edu.degree);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
        currentRow++;

        sheet
            .getRangeByIndex(currentRow, 1)
            .setText('${edu.institution} | ${edu.fieldOfStudy}');
        currentRow++;

        sheet
            .getRangeByIndex(currentRow, 1)
            .setText(
              '${_formatDate(edu.startDate)} - ${edu.endDate != null ? _formatDate(edu.endDate!) : 'Present'}',
            );
        currentRow += 2;
      }
    }

    // Skills
    if (resume.skills.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('SKILLS');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;

      final skillsText = resume.skills
          .map((s) => '${s.name} (${s.level})')
          .join(', ');
      sheet.getRangeByIndex(currentRow, 1).setText(skillsText);
      sheet.getRangeByIndex(currentRow, 1).cellStyle.wrapText = true;
      currentRow += 2;
    }

    // Projects
    if (resume.projects.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('PROJECTS');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;

      for (var project in resume.projects) {
        sheet.getRangeByIndex(currentRow, 1).setText(project.name);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
        currentRow++;

        sheet.getRangeByIndex(currentRow, 1).setText(project.description);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.wrapText = true;
        currentRow++;

        if (project.technologies.isNotEmpty) {
          sheet
              .getRangeByIndex(currentRow, 1)
              .setText('Technologies: ${project.technologies.join(', ')}');
          currentRow++;
        }
        currentRow++;
      }
    }

    // References
    if (resume.references.isNotEmpty) {
      sheet.getRangeByIndex(currentRow, 1).setText('REFERENCES');
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      currentRow++;

      for (var reference in resume.references) {
        sheet.getRangeByIndex(currentRow, 1).setText(reference.name);
        sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
        currentRow++;

        sheet
            .getRangeByIndex(currentRow, 1)
            .setText('${reference.position} at ${reference.company}');
        currentRow++;

        sheet
            .getRangeByIndex(currentRow, 1)
            .setText('Email: ${reference.email} | Phone: ${reference.phone}');
        currentRow += 2;
      }
    }

    // Auto-fit columns
    sheet.autoFitColumn(1);

    // Save as Excel file (opens in Excel/Sheets/Numbers)
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final output = await getApplicationDocumentsDirectory();
    final fileName =
        '${resume.title}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }
}
