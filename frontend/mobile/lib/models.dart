typedef JsonMap = Map<String, dynamic>;

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.nickname,
    required this.age,
    required this.avatar,
  });

  final String id;
  final String nickname;
  final int age;
  final String avatar;

  factory ChildProfile.fromJson(JsonMap json) => ChildProfile(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    age: json['age'] as int,
    avatar: (json['avatar'] as String?) ?? 'fox',
  );
}

class LearningModule {
  const LearningModule({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.progress,
  });

  final String id;
  final String name;
  final String description;
  final String color;
  final JsonMap? progress;

  int get completedActivities =>
      (progress?['completedActivities'] as int?) ?? 0;
  int get stars => (progress?['stars'] as int?) ?? 0;

  factory LearningModule.fromJson(JsonMap json) => LearningModule(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    color: json['color'] as String,
    progress: json['progress'] as JsonMap?,
  );
}

class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.instruction,
    required this.payload,
    required this.rewardStars,
  });

  final String id;
  final String type;
  final String instruction;
  final JsonMap payload;
  final int rewardStars;

  factory ActivityModel.fromJson(JsonMap json) => ActivityModel(
    id: json['id'] as String,
    type: json['type'] as String,
    instruction: json['instruction'] as String,
    payload: json['payload'] as JsonMap,
    rewardStars: json['rewardStars'] as int,
  );
}

class AttemptResult {
  const AttemptResult({
    required this.correct,
    required this.feedback,
    required this.stars,
  });

  final bool correct;
  final String feedback;
  final int stars;

  factory AttemptResult.fromJson(JsonMap json) {
    final earned = (json['earned'] as JsonMap?) ?? const {};
    return AttemptResult(
      correct: json['correct'] as bool,
      feedback: json['feedback'] as String,
      stars: (earned['stars'] as int?) ?? 0,
    );
  }
}
