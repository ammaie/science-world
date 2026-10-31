import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String userId;
  final String status;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final String? activatedByCodeId;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.status,
    this.startsAt,
    this.expiresAt,
    this.activatedByCodeId,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPremium => status == 'premium' && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  bool get isExpired => status == 'premium' && expiresAt != null && expiresAt!.isBefore(DateTime.now());

  int get daysRemaining {
    if (expiresAt == null) return 0;
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      status: map['status'] as String,
      startsAt: map['starts_at'] != null ? DateTime.parse(map['starts_at']) : null,
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      activatedByCodeId: map['activated_by_code_id'] as String?,
      source: map['source'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  List<Object?> get props => [id, userId, status, startsAt, expiresAt, activatedByCodeId, source, createdAt, updatedAt];
}