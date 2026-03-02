import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'login_controller.dart';
import '../logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockCountdown = 0;
  Timer? _timer;

  void _handleLogin() {
    if (_isLocked) return;

    String user = _userController.text;
    String pass = _passController.text;

    if (_controller.login(user, pass)) {
      _failedAttempts = 0;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogView(username: user)));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("Login Berhasil!")]), backgroundColor: Colors.green.shade600, behavior: SnackBarBehavior.floating));
    } else {
      setState(() {
        _failedAttempts++;
        if (_failedAttempts >= 3) _startLockout();
      });
      if (!_isLocked) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 10), Text("Username/Password salah! ($_failedAttempts/3)")]), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _startLockout() {
    _isLocked = true;
    _lockCountdown = 10;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.timer, color: Colors.white), SizedBox(width: 10), Text("Terlalu banyak percobaan. Tunggu 10 detik.")]), backgroundColor: Colors.orange.shade800, behavior: SnackBarBehavior.floating));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_lockCountdown > 1) {
          _lockCountdown--;
        } else {
          _isLocked = false;
          _failedAttempts = 0;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple.shade900, Colors.blue.shade800], begin: Alignment.topLeft, end: Alignment.bottomRight))),
          Positioned(top: -50, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.5), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 100)]))),
          Positioned(bottom: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlueAccent.withOpacity(0.4), boxShadow: [BoxShadow(color: Colors.lightBlueAccent.withOpacity(0.4), blurRadius: 100)]))),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: _isLocked ? Colors.redAccent.withOpacity(0.15) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _isLocked ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: _isLocked ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)),
                          child: Icon(_isLocked ? Icons.timer_rounded : Icons.lock_person_rounded, size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Text(_isLocked ? "Akses Ditangguhkan" : "Welcome Back", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text(_isLocked ? "Tunggu sebentar sebelum mencoba lagi." : "Logbook pintar siap mencatat harimu.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                        const SizedBox(height: 40),

                        TextField(
                          controller: _userController,
                          enabled: !_isLocked,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passController,
                          obscureText: _isObscure,
                          enabled: !_isLocked,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: Material( // Efek Ripple pada IconButton
                              color: Colors.transparent,
                              child: IconButton(
                                splashRadius: 24, // Radius sentuhan yang presisi
                                splashColor: Colors.white.withOpacity(0.3),
                                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                                onPressed: () => setState(() => _isObscure = !_isObscure),
                              ),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLocked ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLocked ? Colors.white30 : Colors.white,
                              foregroundColor: Colors.deepPurple.shade900,
                              splashFactory: InkRipple.splashFactory, // Ripple mewah
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(_isLocked ? "Tunggu $_lockCountdown detik" : "MASUK", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}