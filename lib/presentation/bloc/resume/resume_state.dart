import 'package:equatable/equatable.dart';
import '../../../domain/entities/resume_entity.dart';

abstract class ResumeState extends Equatable {
  const ResumeState();

  @override
  List<Object?> get props => [];
}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumesLoaded extends ResumeState {
  final List<Resume> resumes;

  const ResumesLoaded(this.resumes);

  @override
  List<Object> get props => [resumes];
}

class ResumeLoaded extends ResumeState {
  final Resume resume;

  const ResumeLoaded(this.resume);

  @override
  List<Object> get props => [resume];
}

class ResumeOperationSuccess extends ResumeState {
  final String message;

  const ResumeOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ResumeError extends ResumeState {
  final String message;

  const ResumeError(this.message);

  @override
  List<Object> get props => [message];
}
