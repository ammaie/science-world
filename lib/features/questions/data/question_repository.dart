import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import 'question_model.dart';

class QuestionRepository {
  final SupabaseClient? _client;

  QuestionRepository({SupabaseClient? client})
      : _client = client ?? (SupabaseConfig.isConfigured ? Supabase.instance.client : null);

  Future<List<QuestionModel>> fetchAll({
    String? grade,
    String? subject,
    bool onlyFree = true,
    String? type,
    String? difficulty,
    int limit = 100,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        var query = client.from('questions').select();
        if (grade != null) query = query.eq('grade', grade);
        if (subject != null) query = query.eq('subject', subject);
        if (type != null) query = query.eq('type', type);
        if (difficulty != null) query = query.eq('difficulty', difficulty);
        if (onlyFree) query = query.eq('is_paid', false);
        final response = await query.limit(limit).order('created_at', ascending: false);
        final remote = (response as List<dynamic>)
            .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (remote.isNotEmpty) return remote;
      } catch (_) {
        // Keep the study bank usable when Supabase is offline or not configured correctly.
      }
    }
    return _fetchLocal(grade: grade, subject: subject, onlyFree: onlyFree,
        type: type, difficulty: difficulty, limit: limit);
  }

  Future<List<QuestionModel>> _fetchLocal({
    String? grade, String? subject, required bool onlyFree,
    String? type, String? difficulty, required int limit,
  }) async {
    final raw = await rootBundle.loadString('assets/data/question_bank_ar.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['questions'] as List<dynamic>)
        .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
        .where((q) => grade == null || _sameGrade(q.grade, grade))
        .where((q) => subject == null || q.subject == subject)
        .where((q) => !onlyFree || !q.isPaid)
        .where((q) => type == null || q.type == type)
        .where((q) => difficulty == null || q.difficulty == difficulty)
        .take(limit)
        .toList();
    return list;
  }

  bool _sameGrade(String stored, String requested) {
    final a = stored.replaceAll(' ', '').toLowerCase();
    final b = requested.replaceAll(' ', '').toLowerCase();
    if (a == b) return true;
    const aliases = {
      'التاسع': ['9', 'grade9', 'الصفالتاسع'],
      'العاشر': ['10', 'grade10', 'الصفالعاشر'],
      'الحاديعشرالعلمي': ['11', 'grade11', 'الحاديعشر', 'الصفالحاديعشر'],
      'البكالورياالعلمي': ['12', 'grade12', 'البكالوريا', 'الثالثالثانوي'],
    };
    for (final entry in aliases.entries) {
      final matches = entry.value.contains(a) || entry.value.contains(b) || a == entry.key || b == entry.key;
      if (matches && (a == entry.key || entry.value.contains(a)) && (b == entry.key || entry.value.contains(b))) return true;
    }
    return false;
  }

  Future<QuestionModel> fetchById(String id) async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client.from('questions').select().eq('id', id).single();
        return QuestionModel.fromJson(Map<String, dynamic>.from(response));
      } catch (_) {/* try local data below */}
    }
    final all = await _fetchLocal(grade: null, subject: null, onlyFree: false, type: null, difficulty: null, limit: 10000);
    return all.firstWhere((q) => q.id == id, orElse: () => QuestionModel(
      id: id, grade: '', subject: '', type: 'mcq', source: 'local',
      reviewStatus: 'draft', isPaid: false, correctAnswer: '', solution: '',
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
      questionText: 'السؤال غير متاح حاليا', options: const [],
      explanation: 'لم يتم العثور على السؤال في البنك المحلي أو الخادم.',
    ));
  }

  Future<void> upsert(QuestionModel question) async {
    final client = _client;
    if (client == null) throw StateError('Supabase غير مهيأ؛ لا يمكن حفظ السؤال في الخادم.');
    await client.from('questions').upsert(question.toJson());
  }
}
