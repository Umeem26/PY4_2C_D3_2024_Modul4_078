import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  final List<String> _categories = ['Pribadi', 'Pekerjaan', 'Urgent', 'Lainnya'];
  String _selectedCategory = 'Pribadi';

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await LogHelper.writeLog("UI: Memulai inisialisasi database...", source: "log_view.dart");
      await LogHelper.writeLog("UI: Menghubungi MongoService.connect()...", source: "log_view.dart");

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist."),
      );

      await LogHelper.writeLog("UI: Koneksi MongoService BERHASIL.", source: "log_view.dart");
      await LogHelper.writeLog("UI: Memanggil controller.loadFromDisk()...", source: "log_view.dart");

      await _controller.loadFromDisk();

      await LogHelper.writeLog("UI: Data berhasil dimuat ke Notifier.", source: "log_view.dart");
    } catch (e) {
      await LogHelper.writeLog("UI: Error - $e", source: "log_view.dart", level: 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent': return const Color(0xFFFF5252);
      case 'Pekerjaan': return const Color(0xFF448AFF);
      case 'Pribadi': return const Color(0xFF00BFA5);
      default: return const Color(0xFFFFB300);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Urgent': return Icons.local_fire_department_rounded;
      case 'Pekerjaan': return Icons.work_rounded;
      case 'Pribadi': return Icons.person_rounded;
      default: return Icons.dashboard_customize_rounded;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: Icon(Icons.exit_to_app_rounded, size: 48, color: Colors.red.shade400)),
            const SizedBox(height: 24),
            const Text("Sampai Jumpa!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text("Apakah Anda yakin ingin keluar dari sesi ini?", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54)),
            const SizedBox(height: 32),
            Row(
                children: [
            Expanded(
            child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: Colors.grey.shade600,
        ),
        child: const Text("Batal", style: TextStyle(color: Colors.black54,