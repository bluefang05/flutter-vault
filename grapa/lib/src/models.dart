part of '../main.dart';

class Mission {
  Mission(
    this.title,
    this.subtitle,
    this.categoryAsset,
    this.color, {
    this.done = false,
    this.rewardedToday = false,
  });

  String title;
  String subtitle;
  String categoryAsset;
  Color color;
  bool done;
  bool rewardedToday;

  Map<String, Object> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'categoryAsset': categoryAsset,
    'color': color.toARGB32(),
    'done': done,
    'rewardedToday': rewardedToday,
  };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    json['title'] as String,
    json['subtitle'] as String,
    json['categoryAsset'] as String,
    Color(json['color'] as int),
    done: json['done'] as bool? ?? false,
    rewardedToday: json['rewardedToday'] as bool? ?? false,
  );
}

class MissionDraft {
  const MissionDraft(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
