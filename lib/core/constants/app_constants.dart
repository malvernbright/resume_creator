class AppConstants {
  // App Info
  static const String appName = 'Resume Creator';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'resume_creator.db';
  static const int dbVersion = 1;

  // Tables
  static const String userTable = 'users';
  static const String resumeTable = 'resumes';
  static const String cvTable = 'cvs';
  static const String experienceTable = 'experiences';
  static const String educationTable = 'education';
  static const String skillTable = 'skills';
  static const String achievementTable = 'achievements';
  static const String projectTable = 'projects';
  static const String languageTable = 'languages';
  static const String referenceTable = 'references';

  // File types
  static const String pdfExtension = '.pdf';
  static const String docxExtension = '.docx';

  // Validation
  static const int maxNameLength = 100;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;
  static const int maxDescriptionLength = 500;
  static const int maxSummaryLength = 1000;
}
