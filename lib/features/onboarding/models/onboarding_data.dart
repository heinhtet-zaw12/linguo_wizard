import 'package:flutter/material.dart';

/// User selections from the onboarding flow.
class OnboardingData {
  final String targetLanguage;
  final String cefrLevel;
  final String goal;

  const OnboardingData({
    required this.targetLanguage,
    required this.cefrLevel,
    required this.goal,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      targetLanguage: json['targetLanguage'] as String? ?? 'English',
      cefrLevel: json['cefrLevel'] as String? ?? 'A1',
      goal: json['goal'] as String? ?? 'Travel',
    );
  }

  Map<String, dynamic> toJson() => {
        'targetLanguage': targetLanguage,
        'cefrLevel': cefrLevel,
        'goal': goal,
      };
}

// ─── Preset options ───

const List<MapEntry<IconData, String>> kLanguages = [
  MapEntry(Icons.translate, 'English'),
  MapEntry(Icons.translate, 'Spanish'),
  MapEntry(Icons.translate, 'French'),
  MapEntry(Icons.translate, 'Japanese'),
  MapEntry(Icons.translate, 'Korean'),
  MapEntry(Icons.translate, 'Mandarin'),
];

const List<String> kCefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

const List<MapEntry<IconData, String>> kGoals = [
  MapEntry(Icons.flight, 'Travel'),
  MapEntry(Icons.work, 'Work'),
  MapEntry(Icons.quiz, 'Exam'),
  MapEntry(Icons.chat_bubble, 'Casual'),
];
