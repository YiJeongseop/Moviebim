import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:http/http.dart" as http;

import '../models/movie_model.dart';
import '../utilities/db_helper.dart';
import '../utilities/snack_bar.dart';
import '../widgets/loading_widget.dart';

const String fileName = 'test5.json'; // test5.json for release
final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope]
);

Future<void> signInWithGoogle(BuildContext context) async {
  Get.dialog(const LoadingWidget(), barrierDismissible: false);
  GoogleSignInAccount? googleUser;

  try{
    googleUser = await googleSignIn.signIn();
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return;
  }

  if(googleUser == null){
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return;
  }

  try{
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Get.back();
    Get.back();
    return;
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return;
  }
}


Future<drive.DriveApi?> _getDriveApi() async {
  final googleUser = await googleSignIn.signInSilently();
  final headers = await googleUser?.authHeaders;
  final client = GoogleAuthClient(headers!);
  final driveApi = drive.DriveApi(client);
  return driveApi;
}

Future<void> uploadToDrive(List<MovieModel> movies, BuildContext context) async {
  drive.DriveApi? driveApi;

  try{
    driveApi = await _getDriveApi();
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return;
  }

  List<Map<String, dynamic>> jsonList = moviesToJsonList(movies);
  final jsonData1 = jsonEncode(jsonList);
  final jsonData2 = utf8.encode(jsonData1);

  final driveFile = drive.File();
  driveFile.name = fileName;

  final media = drive.Media(Stream.value(utf8.encode(jsonData1)), jsonData2.length);
  try{
    await driveApi!.files.create(driveFile, uploadMedia: media);
    Get.back();
    Get.back();
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
  }
}

List<Map<String, dynamic>> moviesToJsonList(List<MovieModel> movies) {
  List<Map<String, dynamic>> jsonList = [];
  for (MovieModel movie in movies) {
    jsonList.add(
      {
        'title': movie.title,
        'posterPath': movie.posterPath,
        'rating': movie.rating.toString(),
        'comment': movie.comment,
        'dateTime': movie.dateTime.toString().split(' ')[0],
        'runtime': movie.runtime.toString(),
      }
    );
  }
  return jsonList;
}

Future<List<dynamic>?> downloadFromDrive(BuildContext context) async {
  final List<dynamic> returnList = [[], [
    {5 : []}, {4.5 :[]}, {4 : []}, {3.5 :[]}, {3 : []}, {2.5 :[]}, {2 : []}, {1.5 :[]}, {1 : []}, {0.5 :[]}
  ]];
  drive.DriveApi? driveApi;
  String? fileId;

  try{
    driveApi = await _getDriveApi();
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return null;
  }

  try{
    fileId = await getFileIdByName(fileName);
  } catch (e) {
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.failed);
    return null;
  }

  if(fileId == null){
    Get.back();
    Get.back();
    showSnackBar(context, AppLocalizations.of(context)!.noSavedFiles);
    return null;
  }

  final response = await driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media?;

  final moviesJson = utf8.decode((await response?.stream.toBytes()) as List<int>);
  final moviesList = List<Map<String, dynamic>>.from(jsonDecode(moviesJson));

  for (Map<String, dynamic> movie in moviesList) {
    DateTime dateTime = DateTime.parse(movie['dateTime']);
    bool dateExist = returnList[0].any((map) {
      if(map.keys.first == dateTime){
        return true;
      }
      return false;
    });

    final movieModel = MovieModel(
      title: movie['title'],
      posterPath: movie['posterPath'],
      rating: double.parse(movie['rating']),
      comment: movie['comment'],
      dateTime: dateTime,
      runtime: int.parse(movie['runtime']),
    );

    if(dateExist) {
      for (int i = 0; i < returnList[0].length; i++){
        if(returnList[0][i].keys.first == dateTime){
          returnList[0][i][dateTime].add(movieModel);
        }
      }
    } else {
      returnList[0].add({dateTime: [movieModel]});
    }

    returnList[1][starToIndex[movieModel.rating]][movieModel.rating].add(movieModel);
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
    returnList[1][i][indexToStar[i]].sort((a, b) {
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

Future<String?> getFileIdByName(String fileName) async {
  final driveApi = await _getDriveApi();
  final fileList = await driveApi?.files.list(q: "name = '$fileName'");

  if (fileList!.files!.isNotEmpty) {
    final fileId = fileList.files!.first.id;
    return fileId;
  } else {
    return null;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}