import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'database_helper.dart';

class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource(this.databaseHelper);

  Future<void> saveUser(UserModel user) async {
    try {
      print('💾 Saving user to local database: ${user.email}');
      final db = await databaseHelper.database;
      final result = await db.insert(
        AppConstants.userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ User saved to database with result: $result');
    } catch (e) {
      print('❌ Failed to save user to database: $e');
      throw AppDatabaseException('Failed to save user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.userTable,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromJson(maps.first);
    } catch (e) {
      throw AppDatabaseException('Failed to get user: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.userTable,
        orderBy: 'updatedAt DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromJson(maps.first);
    } catch (e) {
      throw AppDatabaseException('Failed to get current user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.userTable,
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to delete user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.userTable,
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to update user: $e');
    }
  }

  Future<void> clearAllUsers() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(AppConstants.userTable);
    } catch (e) {
      throw AppDatabaseException('Failed to clear users: $e');
    }
  }
}
