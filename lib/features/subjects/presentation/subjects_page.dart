import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المواد')), 
      body: const Center(child: Text('قائمة المواد ستظهر هنا')),
    );
  }
}
