import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/resume_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/local/resume_local_datasource.dart';
import '../models/resume_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final ResumeLocalDataSource localDataSource;

  ResumeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Resume>>> getAllResumes(String userId) async {
    try {
      final resumes = await localDataSource.getAllResumes(userId);
      return Right(resumes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Resume>> getResumeById(String id) async {
    try {
      final resume = await localDataSource.getResumeById(id);
      if (resume == null) {
        return const Left(CacheFailure('Resume not found'));
      }
      return Right(resume);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createResume(Resume resume) async {
    try {
      final resumeModel = ResumeModel(
        id: resume.id,
        userId: resume.userId,
        title: resume.title,
        fullName: resume.fullName,
        email: resume.email,
        phone: resume.phone,
        address: resume.address,
        website: resume.website,
        linkedIn: resume.linkedIn,
        github: resume.github,
        summary: resume.summary,
        experiences: resume.experiences,
        education: resume.education,
        skills: resume.skills,
        achievements: resume.achievements,
        projects: resume.projects,
        languages: resume.languages,
        references: resume.references,
        createdAt: resume.createdAt,
        updatedAt: resume.updatedAt,
      );
      await localDataSource.cacheResume(resumeModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateResume(Resume resume) async {
    try {
      final resumeModel = ResumeModel(
        id: resume.id,
        userId: resume.userId,
        title: resume.title,
        fullName: resume.fullName,
        email: resume.email,
        phone: resume.phone,
        address: resume.address,
        website: resume.website,
        linkedIn: resume.linkedIn,
        github: resume.github,
        summary: resume.summary,
        experiences: resume.experiences,
        education: resume.education,
        skills: resume.skills,
        achievements: resume.achievements,
        projects: resume.projects,
        languages: resume.languages,
        references: resume.references,
        createdAt: resume.createdAt,
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateResume(resumeModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    try {
      await localDataSource.deleteResume(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
