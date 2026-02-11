import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late Map<DateTime, bool> completions;

  @HiveField(2)
  late String category;

  Habit({
    required this.name,
    required this.category,
    Map<DateTime, bool>? completions,
  }) : completions = completions ?? {};

  // Mark habit for today
  void markForToday(bool completed) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    completions[today] = completed;
  }

  // Check if habit is completed today
  bool isCompletedToday() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return completions[today] ?? false;
  }

  // Get completion rate
  double getCompletionRate() {
    if (completions.isEmpty) return 0.0;
    final completedCount = completions.values.where((v) => v).length;
    return completedCount / completions.length;
  }
}
