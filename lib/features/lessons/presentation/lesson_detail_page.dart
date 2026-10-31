import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الدرس')),
      body: const Center(child: Text('تفاصيل الدرس ستظهر هنا')),
    );
  }
}
