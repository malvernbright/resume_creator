import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/resume_repository.dart';
import 'resume_event.dart';
import 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ResumeRepository resumeRepository;

  ResumeBloc(this.resumeRepository) : super(ResumeInitial()) {
    on<LoadResumes>(_onLoadResumes);
    on<LoadResumeById>(_onLoadResumeById);
    on<CreateResume>(_onCreateResume);
    on<UpdateResume>(_onUpdateResume);
    on<DeleteResume>(_onDeleteResume);
  }

  Future<void> _onLoadResumes(
    LoadResumes event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());
    final result = await resumeRepository.getAllResumes(event.userId);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resumes) => emit(ResumesLoaded(resumes)),
    );
  }

  Future<void> _onLoadResumeById(
    LoadResumeById event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());
    final result = await resumeRepository.getResumeById(event.id);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resume) => emit(ResumeLoaded(resume)),
    );
  }

  Future<void> _onCreateResume(
    CreateResume event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());
    final result = await resumeRepository.createResume(event.resume);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (_) => emit(const ResumeOperationSuccess('Resume created successfully')),
    );
  }

  Future<void> _onUpdateResume(
    UpdateResume event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());
    final result = await resumeRepository.updateResume(event.resume);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (_) => emit(const ResumeOperationSuccess('Resume updated successfully')),
    );
  }

  Future<void> _onDeleteResume(
    DeleteResume event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());
    final result = await resumeRepository.deleteResume(event.id);
    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (_) => emit(const ResumeOperationSuccess('Resume deleted successfully')),
    );
  }
}
