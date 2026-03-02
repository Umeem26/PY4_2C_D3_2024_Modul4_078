import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

// --- JALUR IMPORT YANG SUDAH DISESUAIKAN ---
import 'models/log_model.dart'; // Karena model ada di dalam folder logbook yang sama
import '../../services/mongo_service.dart'; // Mundur ke lib/ lalu masuk ke services
import '../../helpers/log_helper.dart'; // Mundur ke lib/ lalu masuk ke helpers

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier<List<LogModel>>([]);

  List<LogModel> get logs => logsNotifier.value;

  LogController() {
    loadFromDisk();
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString(),
    );

    try {
      await MongoService().insertLog(newLog);

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Add - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> updateLog(int index, String newTitle, String newDesc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      category: category,
      date: DateTime.now().toString(),
    );

    try {
      await MongoService().updateLog(updatedLog);

      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception("ID Log tidak ditemukan, tidak bisa menghapus di Cloud.");
      }

      await MongoService().deleteLog(targetLog.id!);

      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> loadFromDisk() async {
    try {
      final cloudData = await MongoService().getLogs();
      logsNotifier.value = cloudData;
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal memuat data dari Cloud - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }
}