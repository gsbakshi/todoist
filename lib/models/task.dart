class Task {
  String id;
  String title;
  String description;
  DateTime createdAt;
  bool completed;
  DateTime completedAt;

  Task({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.completed = false,
    this.completedAt,
  });
}
