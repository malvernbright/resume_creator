import 'package:equatable/equatable.dart';
import 'common_entities.dart';

class Resume extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String? website;
  final String? linkedIn;
  final String? github;
  final String summary;
  final List<Experience> experiences;
  final List<Education> education;
  final List<Skill> skills;
  final List<Achievement> achievements;
  final List<Project> projects;
  final List<Language> languages;
  final List<Reference> references;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.website,
    this.linkedIn,
    this.github,
    required this.summary,
    this.experiences = const [],
    this.education = const [],
    this.skills = const [],
    this.achievements = const [],
    this.projects = const [],
    this.languages = const [],
    this.references = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    fullName,
    email,
    phone,
    address,
    website,
    linkedIn,
    github,
    summary,
    experiences,
    education,
    skills,
    achievements,
    projects,
    languages,
    references,
    createdAt,
    updatedAt,
  ];
}
