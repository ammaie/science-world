import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الإجابات')),
      body: const Center(child: Text('مراجعة الإجابات ستظهر هنا')),
    );
  }
}
