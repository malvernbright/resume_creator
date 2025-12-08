import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/resume_entity.dart';

abstract class ResumeRepository {
  Future<Either<Failure, List<Resume>>> getAllResumes(String userId);
  Future<Either<Failure, Resume>> getResumeById(String id);
  Future<Either<Failure, void>> createResume(Resume resume);
  Future<Either<Failure, void>> updateResume(Resume resume);
  Future<Either<Failure, void>> deleteResume(String id);
}
