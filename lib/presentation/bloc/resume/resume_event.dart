import 'package:equatable/equatable.dart';
import '../../../domain/entities/resume_entity.dart';

abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

class LoadResumes extends ResumeEvent {
  final String userId;

  const LoadResumes(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateResume extends ResumeEvent {
  final Resume resume;

  const CreateResume(this.resume);

  @override
  List<Object> get props => [resume];
}

class UpdateResume extends ResumeEvent {
  final Resume resume;

  const UpdateResume(this.resume);

  @override
  List<Object> get props => [resume];
}

class DeleteResume extends ResumeEvent {
  final String id;

  const DeleteResume(this.id);

  @override
  List<Object> get props => [id];
}

class LoadResumeById extends ResumeEvent {
  final String id;

  const LoadResumeById(this.id);

  @override
  List<Object> get props => [id];
}
