import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Pribadi', 'Pekerjaan', 'Urgent', 'Lainnya'];
  String _selectedCategory = 'Pribadi';

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
                        foregroundColor: Colors.grey.shade600, // Ripple color
                      ),
                      child: const Text("Batal", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogForm({int? index, LogModel? log}) {
    bool isEdit = index != null && log != null;
    _titleController.text = isEdit ? log.title : '';
    _contentController.text = isEdit ? log.description : '';
    _selectedCategory = isEdit ? log.category : 'Pribadi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 24),
                    Text(isEdit ? "Perbarui Catatan" : "Catatan Baru", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                    const SizedBox(height: 24),
                    TextField(controller: _titleController, decoration: InputDecoration(labelText: "Judul", prefixIcon: Icon(Icons.title_rounded, color: Colors.deepPurple.shade300), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                    const SizedBox(height: 16),
                    TextField(controller: _contentController, maxLines: 4, decoration: InputDecoration(labelText: "Deskripsi", alignLabelWithHint: true, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                    const SizedBox(height: 24),
                    const Text("Kategori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((cat) {
                        bool isSelected = _selectedCategory == cat;
                        Color catColor = _getCategoryColor(cat);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? catColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? catColor : Colors.grey.shade300, width: 1.5),
                            boxShadow: isSelected ? [BoxShadow(color: catColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                          ),
                          // MATERIAL & INKWELL: Menambah efek sentuhan pada kategori
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setStateSheet(() => _selectedCategory = cat),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getCategoryIcon(cat), size: 18, color: isSelected ? Colors.white : Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(cat, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade700,
                          foregroundColor: Colors.white,
                          splashFactory: InkRipple.splashFactory, // Ripple pada tombol simpan
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          shadowColor: Colors.deepPurple.shade200,
                        ),
                        onPressed: () {
                          if (isEdit) {
                            _controller.updateLog(index, _titleController.text, _contentController.text, _selectedCategory);
                          } else {
                            _controller.addLog(_titleController.text, _contentController.text, _selectedCategory);
                          }
                          _titleController.clear();
                          _contentController.clear();
                          Navigator.pop(context);
                        },
                        child: Text(isEdit ? "Simpan Perubahan" : "Simpan Catatan", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple.shade800, Colors.blue.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.person_rounded, size: 28, color: Colors.deepPurple.shade600))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Halo, ${widget.username} 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 4), Text("Punya rencana apa hari ini?", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)))])),
                Material( // MATERIAL & INKWELL: Ripple pada ikon Logout
                  color: Colors.transparent,
                  child: IconButton(
                    splashRadius: 24,
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
                    onPressed: _showLogoutConfirmation,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))]),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _controller.searchLog(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Cari logbook...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.deepPurple.shade400),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Material( // Ripple pada tombol clear pencarian
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _controller.searchLog('');
                        setState(() {});
                      },
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20)]), child: Icon(Icons.folder_open_rounded, size: 70, color: Colors.deepPurple.shade200)), const SizedBox(height: 24), const Text("Belum ada catatan.\nAyo buat logbook pertamamu!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5))]));
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    Color categoryColor = _getCategoryColor(log.category);

                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Hapus Catatan?", style: TextStyle(fontWeight: FontWeight.bold)), content: const Text("Tindakan ini tidak dapat dibatalkan."), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal", style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500, foregroundColor: Colors.white, elevation: 0), onPressed: () => Navigator.of(context).pop(true), child: const Text("Hapus"))]);
                          },
                        );
                      },
                      background: Container(margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(20)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 25), child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32)),
                      onDismissed: (direction) {
                        _controller.removeLog(index);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Catatan dihapus"), backgroundColor: Colors.red.shade500, behavior: SnackBarBehavior.floating));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: categoryColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))]),
                        // MATERIAL & INKWELL: Ripple Effect saat kartu di-tap!
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _showLogForm(index: index, log: log), // Klik kartu otomatis membuka form edit
                            splashColor: categoryColor.withOpacity(0.1),
                            highlightColor: categoryColor.withOpacity(0.05),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(_getCategoryIcon(log.category), color: categoryColor, size: 28)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                                        const SizedBox(height: 6),
                                        Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(log.category.toUpperCase(), style: TextStyle(fontSize: 11, color: categoryColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                            // INKWELL UNTUK TOMBOL EDIT
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                onTap: () => _showLogForm(index: index, log: log),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                                  child: Row(children: [Icon(Icons.edit_rounded, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600))]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
        child: FloatingActionButton(
          onPressed: () => _showLogForm(),
          backgroundColor: Colors.blue.shade600,
          splashColor: Colors.white.withOpacity(0.3), // Ripple cerah pada FAB
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}