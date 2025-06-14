class Task {
  final String id;
  final String text;

  Task({required this.id, required this.text});

  /* ------------  JSON ------------- */

  /// JSON ➜ Task
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String, //  <- klucze *id* i *text*
    text: json['text'] as String,
  );

  /// Task ➜ JSON  (raczej niepotrzebne, ale zostawmy)
  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}
