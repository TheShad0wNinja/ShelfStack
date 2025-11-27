import 'package:flutter/material.dart';
import 'package:shelfstack/app.dart';
import 'package:shelfstack/data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(const MyApp());
}
