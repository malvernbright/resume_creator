import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/resume_model.dart';
import 'database_helper.dart';

class ResumeLocalDataSource {
  final DatabaseHelper databaseHelper;

  ResumeLocalDataSource(this.databaseHelper);

  Future<void> cacheResume(ResumeModel resume) async {
    try {
      await databaseHelper.insert(AppConstants.resumeTable, resume.toJson());
    } catch (e) {
      throw CacheException('Failed to cache resume: $e');
    }
  }

  Future<List<ResumeModel>> getAllResumes(String userId) async {
    try {
      final results = await databaseHelper.query(
        AppConstants.resumeTable,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return results.map((json) => ResumeModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get resumes: $e');
    }
  }

  Future<ResumeModel?> getResumeById(String id) async {
    try {
      final results = await databaseHelper.query(
        AppConstants.resumeTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) return null;
      return ResumeModel.fromJson(results.first);
    } catch (e) {
      throw CacheException('Failed to get resume: $e');
    }
  }

  Future<void> updateResume(ResumeModel resume) async {
    try {
      await databaseHelper.update(
        AppConstants.resumeTable,
        resume.toJson(),
        'id = ?',
        [resume.id],
      );
    } catch (e) {
      throw CacheException('Failed to update resume: $e');
    }
  }

  Future<void> deleteResume(String id) async {
    try {
      await databaseHelper.delete(AppConstants.resumeTable, 'id = ?', [id]);
    } catch (e) {
      throw CacheException('Failed to delete resume: $e');
    }
  }
}
