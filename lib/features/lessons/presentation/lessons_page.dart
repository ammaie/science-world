import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدروس')),
      body: const Center(child: Text('قائمة الدروس ستظهر هنا')),
    );
  }
}
