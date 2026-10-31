import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_service.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});
  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final _email = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _msg;

  Future<void> _send() async {
    setState(() { _loading = true; _msg = null; });
    try {
      await _auth.resetPassword(_email.text.trim());
      setState(() => _msg = 'تم إرسال رابط إعادة التعيين.');
    } catch (e) {
      setState(() => _msg = 'تعذر الإرسال.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
            if (_msg != null) ...[const SizedBox(height: 8), Text(_msg!)],
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _send, child: _loading ? const CircularProgressIndicator() : const Text('إرسال'))),
          ],
        ),
      ),
    );
  }
}