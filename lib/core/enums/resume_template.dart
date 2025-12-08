enum ResumeTemplate { classic, modern, professional, minimalist }

extension ResumeTemplateExtension on ResumeTemplate {
  String get displayName {
    switch (this) {
      case ResumeTemplate.classic:
        return 'Classic';
      case ResumeTemplate.modern:
        return 'Modern';
      case ResumeTemplate.professional:
        return 'Professional';
      case ResumeTemplate.minimalist:
        return 'Minimalist';
    }
  }

  String get description {
    switch (this) {
      case ResumeTemplate.classic:
        return 'Traditional format with clear sections';
      case ResumeTemplate.modern:
        return 'Contemporary design with accent colors';
      case ResumeTemplate.professional:
        return 'Clean and corporate style';
      case ResumeTemplate.minimalist:
        return 'Simple and elegant layout';
    }
  }
}
