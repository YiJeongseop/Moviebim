import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'package:path/path.dart';
import '../models/movie_model.dart';

const String dbName = 'test2.db';
const String tableMovie = 'tableMovie';
const String columnTitle = 'title';
const String columnPosterPath = 'posterPath';
const String columnRating = 'rating';
const String columnComment = 'comment';
const String columnDateTime = 'dateTime';

class DBHelper {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableMovie(
            $columnTitle TEXT NOT NULL,
            $columnPosterPath TEXT NOT NULL,
            $columnRating REAL NOT NULL,
            $columnComment TEXT,
            $columnDateTime TEXT NOT NULL)
        ''');
      }
    );
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    final batch = db!.batch();
    batch.insert(tableMovie, data);
    await batch.commit();
  }

  // Future<void> insertAllData(List<Appointment> appointments) async {
  //   final db = await database;
  //   await db!.rawDelete("DELETE FROM $tableAppointment");
  //   final batch = db.batch();
  //
  //   List<Map<String, dynamic>> jsonList = appointmentsToJsonList(appointments, false);
  //   for(int i = 0; i < jsonList.length; i++){
  //     batch.insert(tableAppointment, jsonList[i]);
  //   }
  //
  //   await batch.commit();
  // }

  Future<void> deleteData(String title, String posterPath, num rating, String comment, DateTime dateTime) async {
    final dateStr = dateTime.toString().split(' ')[0];
    final db = await database;
    await db!.delete(
        tableMovie,
        where: '$columnTitle = ? and $columnPosterPath = ? and $columnRating = ? and $columnComment = ? and $columnDateTime = ?',
        whereArgs: [title, posterPath, rating, comment, dateStr]
    );
  }

  // Future<void> deleteAllData() async {
  //   final db = await database;
  //   await db!.rawDelete("DELETE FROM $tableMovie");
  // }

  Future<void> updateData(num rating, String comment, MovieModel before) async {
    final db = await database;
    final dateStr = before.dateTime.toString().split(' ')[0];
    final batch = db!.batch();
    batch.update(
      tableMovie,
      {columnRating: rating, columnComment: comment},
      where: '$columnTitle = ? and $columnPosterPath = ? and $columnRating = ? and $columnComment = ? and $columnDateTime = ?',
      whereArgs: [before.title, before.posterPath, before.rating, before.comment, dateStr]
    );
    await batch.commit();
  }

  Future<List<dynamic>> getData() async {
    final db = await database;
    final List<Map<String, dynamic>> movieList = await db!.query(tableMovie);
    final List<dynamic> returnList = [[], [
      {5 : []}, {4.5 :[]}, {4 : []}, {3.5 :[]}, {3 : []}, {2.5 :[]}, {2 : []}, {1.5 :[]}, {1 : []}, {0.5 :[]}
    ]];

    for (Map<String, dynamic> movie in movieList){
      DateTime dateTime = DateTime.parse(movie[columnDateTime]);
      bool dateExist = returnList[0].any((map) {
        if(map.keys.first == dateTime){
          return true;
        }
        return false;
      });
      final movieModel = MovieModel(
          title: movie[columnTitle],
          posterPath: movie[columnPosterPath],
          rating: movie[columnRating].toDouble(),
          comment: movie[columnComment],
          dateTime: dateTime
      );
      if(dateExist) {
        for (int i = 0; i < returnList[0].length; i++){
          if(returnList[0][i].keys.elementAt(0) == dateTime){
            returnList[0][i][dateTime].add(movieModel);
            break;
          }
        }
      } else {
        returnList[0].add({dateTime : [movieModel]});
      }

      Map<double, int> temp = {5 : 0, 4.5 : 1, 4 : 2, 3.5 : 3, 3 : 4, 2.5 : 5,
      2 : 6, 1.5 : 7, 1 : 8, 0.5 : 9};

      returnList[1][temp[movie[columnRating].toDouble()]][movie[columnRating].toDouble()].add(movieModel);
    }

    returnList[0].sort((a, b) {
      final DateTime dateA = a.keys.first;
      final DateTime dateB = b.keys.first;
      if (dateA.isBefore(dateB)) {
        return -1;
      } else if (dateA.isAfter(dateB)) {
        return 1;
      } else {
        return 0;
      }
    });

    for(int i = 0; i < 10; i++){
      List<double> star = [5, 4.5, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5];

      returnList[1][i][star[i]].sort((a, b) {
        final DateTime dateA = a.dateTime;
        final DateTime dateB = b.dateTime;
        if (dateA.isBefore(dateB)) {
          return -1;
        } else if (dateA.isAfter(dateB)) {
          return 1;
        } else {
          return 0;
        }
      });
    }

    return returnList;
  }
}