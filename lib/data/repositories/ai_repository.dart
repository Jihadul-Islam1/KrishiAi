import 'package:uuid/uuid.dart';

import '../models/ai_chat.dart';
import '../models/diagnosis.dart';
import '../models/disease.dart';
import 'disease_repository.dart';
import 'local_store.dart';

const _uuid = Uuid();

class AIRepository {
  AIRepository(this._diseaseRepo, this._store);

  final DiseaseLibraryRepository _diseaseRepo;
  final LocalStore _store;

  static const _historyKey = 'ai_chat_history';

  Future<Diagnosis> analyzeImagePlaceholder({
    required String cropName,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final library = await _diseaseRepo.all();
    final lower = cropName.toLowerCase();
    Disease match = library.first;
    for (final d in library) {
      if (d.cropName.toLowerCase() == lower) {
        match = d;
        break;
      }
    }
    return Diagnosis(
      id: _uuid.v4(),
      cropName: cropName,
      diseaseName: match.name,
      confidence: 0.85,
      severity: match.severity,
      scannedAt: DateTime.now(),
      symptoms: match.symptoms,
      causes: match.causes,
      management: match.management,
      prevention: match.prevention,
      notes: notes,
    );
  }

  Future<AIConversation> loadConversation() async {
    final raw = _store.readJson(_historyKey);
    if (raw is Map<String, dynamic>) {
      try {
        return AIConversation.fromJson(raw);
      } catch (_) {
        // fall through
      }
    }
    final now = DateTime.now();
    return AIConversation(
      id: _uuid.v4(),
      title: 'নতুন কথোপকথন',
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<AIConversation> appendMessage(
    AIConversation conv,
    AIMessage message,
  ) async {
    final updated = conv.copyWith(
      messages: [...conv.messages, message],
      updatedAt: DateTime.now(),
    );
    await _store.writeJson(_historyKey, updated.toJson());
    return updated;
  }

  Future<AIMessage> generateReply(String userText) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final library = await _diseaseRepo.all();
    final lower = userText.toLowerCase();

    for (final d in library) {
      final hit =
          d.symptoms.any((s) => lower.contains(s.toLowerCase())) ||
          lower.contains(d.cropName.toLowerCase()) ||
          lower.contains(d.name.toLowerCase());
      if (hit) {
        final tips = [
          '• কারণ: ${d.causes.join(', ')}',
          '• প্রতিকার: ${d.management.join(' | ')}',
          '• প্রতিরোধ: ${d.prevention.join(' | ')}',
        ].join('\n');
        return AIMessage(
          id: _uuid.v4(),
          role: AIMessageRole.assistant,
          content:
              'আপনার বর্ণনার ভিত্তিতে এটি হতে পারে: ${d.name}\n\n$tips\n\n⚠️ এটি একটি প্রাথমিক পরামর্শ। সঠিক নির্ণয়ের জন্য ছবি স্ক্যান করুন বা স্থানীয় কৃষি কর্মকর্তার সাথে যোগাযোগ করুন।',
          createdAt: DateTime.now(),
        );
      }
    }

    if (lower.contains('সেচ') || lower.contains('পানি')) {
      return AIMessage(
        id: _uuid.v4(),
        role: AIMessageRole.assistant,
        content:
            'সেচের সাধারণ নিয়ম:\n• সকালে বা সন্ধ্যায় সেচ দিন\n• মাটির আর্দ্রতা পরীক্ষা করুন (আঙুল দিয়ে)\n• ধানে ২-৩ ইঞ্চি পানি রাখুন\n• সবজিতে ড্রিপ সেচ ব্যবহার করলে পানি সাশ্রয় হয়',
        createdAt: DateTime.now(),
      );
    }
    if (lower.contains('সার') || lower.contains('ইউরিয়া')) {
      return AIMessage(
        id: _uuid.v4(),
        role: AIMessageRole.assistant,
        content:
            'সার ব্যবস্থাপনা:\n• মাটি পরীক্ষা করে সার প্রয়োগ করুন\n• নাইট্রোজেন, ফসফরাস, পটাশ সুষমভাবে ব্যবহার করুন\n• জৈব সার ব্যবহারে মাটির গুণাগুণ বাড়ে',
        createdAt: DateTime.now(),
      );
    }
    if (lower.contains('কীট') || lower.contains('পোকা')) {
      return AIMessage(
        id: _uuid.v4(),
        role: AIMessageRole.assistant,
        content:
            'কীটপতঙ্গ নিয়ন্ত্রণ:\n• আক্রান্ত পাতা সংগ্রহ করে ধ্বংস করুন\n• নিমতেল জৈব ব্যবস্থাপনায় কার্যকর\n• ফেরোমন ফাঁদ ব্যবহার করুন\n• স্থানীয় কৃষি কর্মকর্তার পরামর্শ নিন',
        createdAt: DateTime.now(),
      );
    }

    return AIMessage(
      id: _uuid.v4(),
      role: AIMessageRole.assistant,
      content:
          'আমি আপনার প্রশ্ন বুঝতে পেরেছি। আরো বিস্তারিত জানতে নির্দিষ্ট ফসল, রোগ বা সমস্যার নাম বলুন। আমি সাধারণ কৃষি পরামর্শ, রোগ শনাক্তকরণ, সার ও সেচ ব্যবস্থাপনায় সাহায্য করতে পারি।',
      createdAt: DateTime.now(),
    );
  }
}
