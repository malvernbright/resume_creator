import 'package:equatable/equatable.dart';

class Experience extends Equatable {
  final String id;
  final String company;
  final String position;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const Experience({
    required this.id,
    required this.company,
    required this.position,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  @override
  List<Object?> get props => [
    id,
    company,
    position,
    description,
    startDate,
    endDate,
    isCurrent,
  ];
}

class Education extends Equatable {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? grade;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.grade,
  });

  @override
  List<Object?> get props => [
    id,
    institution,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    isCurrent,
    grade,
  ];
}

class Skill extends Equatable {
  final String id;
  final String name;
  final String level; // Beginner, Intermediate, Advanced, Expert
  final String? category;

  const Skill({
    required this.id,
    required this.name,
    required this.level,
    this.category,
  });

  @override
  List<Object?> get props => [id, name, level, category];
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? organization;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.organization,
  });

  @override
  List<Object?> get props => [id, title, description, date, organization];
}

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? url;
  final List<String> technologies;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.url,
    this.technologies = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    isCurrent,
    url,
    technologies,
  ];
}

class Language extends Equatable {
  final String id;
  final String name;
  final String proficiency; // Basic, Conversational, Fluent, Native

  const Language({
    required this.id,
    required this.name,
    required this.proficiency,
  });

  @override
  List<Object?> get props => [id, name, proficiency];
}

class Reference extends Equatable {
  final String id;
  final String name;
  final String position;
  final String company;
  final String email;
  final String phone;

  const Reference({
    required this.id,
    required this.name,
    required this.position,
    required this.company,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, position, company, email, phone];
}
