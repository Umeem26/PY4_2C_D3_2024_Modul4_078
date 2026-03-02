import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  static const String _storageKey = 'user_logs_data';

  LogController() { loadFromDisk(); }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = List.from(logsNotifier.value);
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // 👇 PERHATIKAN: Sekarang sudah menerima 3 parameter (termasuk category)
  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
        title: title, 
        description: desc, 
        date: DateTime.now().toString(),
        category: category, // Menyimpan kategori ke Model
    );
    final newList = List<LogModel>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = newList;
    _syncFilteredLogs(); 
    saveToDisk();
  }

  // 👇 PERHATIKAN: Ini juga sudah menerima parameter category
  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
        title: title, 
        description: desc, 
        date: DateTime.now().toString(),
        category: category, // Menyimpan kategori ke Model
    );
    logsNotifier.value = currentLogs;
    _syncFilteredLogs(); 
    saveToDisk();
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    _syncFilteredLogs(); 
    saveToDisk();
  }

  void _syncFilteredLogs() {
    filteredLogs.value = List<LogModel>.from(logsNotifier.value);
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(logsNotifier.value.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      _syncFilteredLogs(); 
    }
  }
}