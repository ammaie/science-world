import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/gamification_service.dart';
import '../data/question_service.dart';
import '../data/question_model.dart';

class QuestionDetailPage extends StatefulWidget {
  final String questionId;
  const QuestionDetailPage({required this.questionId, super.key});

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  final QuestionService _service = QuestionService();
  QuestionModel? _question;
  bool _loading = true;
  String? _error;
  final _soundService = SoundService();
  final _gamificationService = GamificationService();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = await _service.fetchQuestionById(widget.questionId);
      setState(() {
        _question = q;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل السؤال')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                      ],
                    ),
                  )
                : _question == null
                    ? const Center(child: Text('السؤال غير موجود'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _question!.questionText,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            const Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (_question!.options.isEmpty)
                              const Text('لا توجد خيارات')
                            else
                              Column(
                                children: _question!.options
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final idx = entry.key;
                                      final o = entry.value;
                                      return GestureDetector(
                                        onTap: () async {
                                          final isCorrect = o == _question!.correctAnswer;
                                          if (isCorrect) {
                                            final before = await _gamificationService.load();
                                            final after = await _gamificationService.recordCorrectAnswer();
                                            await _soundService.playCorrect();
                                            await _soundService.playXp();
                                            if (after.level > before.level) await _soundService.playLevelUp();
                                            if (after.achievements.length > before.achievements.length) await _soundService.playAchievement();
                                          } else {
                                            await _soundService.playWrong();
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(isCorrect ? 'إجابة صحيحة، أحسنت!' : 'الإجابة غير صحيحة، حاول مرة أخرى'),
                                                backgroundColor: isCorrect ? Colors.green : Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('${idx + 1}. $o'),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            const SizedBox(height: 16),
                            const Text('الإجابة الصحيحة:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_question!.correctAnswer.isNotEmpty ? _question!.correctAnswer : 'غير محددة'),
                            if (_question!.explanation.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('شرح الحل:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_question!.explanation),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }
}
