import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class StudentProgressPage extends StatefulWidget {
  const StudentProgressPage({super.key});
  @override
  State<StudentProgressPage> createState() => _StudentProgressPageState();
}

class _StudentProgressPageState extends State<StudentProgressPage> {
  bool _loading = true;
  String? _error;
  int _attempts = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      if (!SupabaseConfig.isConfigured) throw Exception('Supabase غير مهيأ');
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      // Read only the signed-in student's own attempts; RLS must enforce ownership.
      final rows = await client.from('exam_attempts').select('id').eq('user_id', user.id);
      _attempts = (rows as List).length;
    } catch (_) {
      _error = 'لا تتوفر بيانات تقدم كافية حاليًا. تأكد من إعداد جدول المحاولات وسياسات RLS.';
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('التقدم الدراسي')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(18), children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.insights_rounded, size: 34), const SizedBox(height: 12),
        Text('رحلتك نحو التفوق', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('نعرض هنا النشاط الذي تم تسجيله فعليًا في حسابك. ستظهر مؤشرات أكثر عند توفر بيانات الدروس والأسئلة.'),
      ]))),
      const SizedBox(height: 12),
      Card(child: ListTile(leading: const Icon(Icons.assignment_turned_in_outlined), title: const Text('محاولات الاختبارات المسجلة'), trailing: Text('$_attempts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)))),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 12), const Text('لم نعرض نسبة إنجاز أو ساعات دراسة تقديرية؛ ستظهر هذه المؤشرات بعد ربط مصادر بياناتها الفعلية.'),
    ]),
  );
}
