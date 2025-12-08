import '../../domain/entities/resume_entity.dart';
import '../../domain/entities/common_entities.dart';
import 'dart:convert';

class ResumeModel extends Resume {
  const ResumeModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.fullName,
    required super.email,
    required super.phone,
    super.address,
    super.website,
    super.linkedIn,
    super.github,
    required super.summary,
    super.experiences,
    super.education,
    super.skills,
    super.achievements,
    super.projects,
    super.languages,
    super.references,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      website: json['website'] as String?,
      linkedIn: json['linkedIn'] as String?,
      github: json['github'] as String?,
      summary: json['summary'] as String,
      experiences: json['experiences'] != null
          ? (jsonDecode(json['experiences'] as String) as List)
                .map((e) => _experienceFromJson(e))
                .toList()
          : [],
      education: json['education'] != null
          ? (jsonDecode(json['education'] as String) as List)
                .map((e) => _educationFromJson(e))
                .toList()
          : [],
      skills: json['skills'] != null
          ? (jsonDecode(json['skills'] as String) as List)
                .map((e) => _skillFromJson(e))
                .toList()
          : [],
      achievements: json['achievements'] != null
          ? (jsonDecode(json['achievements'] as String) as List)
                .map((e) => _achievementFromJson(e))
                .toList()
          : [],
      projects: json['projects'] != null
          ? (jsonDecode(json['projects'] as String) as List)
                .map((e) => _projectFromJson(e))
                .toList()
          : [],
      languages: json['languages'] != null
          ? (jsonDecode(json['languages'] as String) as List)
                .map((e) => _languageFromJson(e))
                .toList()
          : [],
      references: json['references'] != null
          ? (jsonDecode(json['references'] as String) as List)
                .map((e) => _referenceFromJson(e))
                .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'website': website,
      'linkedIn': linkedIn,
      'github': github,
      'summary': summary,
      'experiences': jsonEncode(
        experiences.map((e) => _experienceToJson(e)).toList(),
      ),
      'education': jsonEncode(
        education.map((e) => _educationToJson(e)).toList(),
      ),
      'skills': jsonEncode(skills.map((e) => _skillToJson(e)).toList()),
      'achievements': jsonEncode(
        achievements.map((e) => _achievementToJson(e)).toList(),
      ),
      'projects': jsonEncode(projects.map((e) => _projectToJson(e)).toList()),
      'languages': jsonEncode(
        languages.map((e) => _languageToJson(e)).toList(),
      ),
      'references': jsonEncode(
        references.map((e) => _referenceToJson(e)).toList(),
      ),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Experience _experienceFromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      company: json['company'],
      position: json['position'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
    );
  }

  static Map<String, dynamic> _experienceToJson(Experience exp) {
    return {
      'id': exp.id,
      'company': exp.company,
      'position': exp.position,
      'description': exp.description,
      'startDate': exp.startDate.toIso8601String(),
      'endDate': exp.endDate?.toIso8601String(),
      'isCurrent': exp.isCurrent,
    };
  }

  static Education _educationFromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      institution: json['institution'],
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
      grade: json['grade'],
    );
  }

  static Map<String, dynamic> _educationToJson(Education edu) {
    return {
      'id': edu.id,
      'institution': edu.institution,
      'degree': edu.degree,
      'fieldOfStudy': edu.fieldOfStudy,
      'startDate': edu.startDate.toIso8601String(),
      'endDate': edu.endDate?.toIso8601String(),
      'isCurrent': edu.isCurrent,
      'grade': edu.grade,
    };
  }

  static Skill _skillFromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      category: json['category'],
    );
  }

  static Map<String, dynamic> _skillToJson(Skill skill) {
    return {
      'id': skill.id,
      'name': skill.name,
      'level': skill.level,
      'category': skill.category,
    };
  }

  static Achievement _achievementFromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      organization: json['organization'],
    );
  }

  static Map<String, dynamic> _achievementToJson(Achievement ach) {
    return {
      'id': ach.id,
      'title': ach.title,
      'description': ach.description,
      'date': ach.date.toIso8601String(),
      'organization': ach.organization,
    };
  }

  static Project _projectFromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
      url: json['url'],
      technologies: List<String>.from(json['technologies'] ?? []),
    );
  }

  static Map<String, dynamic> _projectToJson(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'startDate': project.startDate.toIso8601String(),
      'endDate': project.endDate?.toIso8601String(),
      'isCurrent': project.isCurrent,
      'url': project.url,
      'technologies': project.technologies,
    };
  }

  static Language _languageFromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
      proficiency: json['proficiency'],
    );
  }

  static Map<String, dynamic> _languageToJson(Language lang) {
    return {'id': lang.id, 'name': lang.name, 'proficiency': lang.proficiency};
  }

  static Reference _referenceFromJson(Map<String, dynamic> json) {
    return Reference(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      company: json['company'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  static Map<String, dynamic> _referenceToJson(Reference ref) {
    return {
      'id': ref.id,
      'name': ref.name,
      'position': ref.position,
      'company': ref.company,
      'email': ref.email,
      'phone': ref.phone,
    };
  }
}
