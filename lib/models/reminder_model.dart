class Reminder {
  final String title;
  final String time;

  Reminder({required this.title, required this.time});

  Map<String, String> toMap() => {'title': title, 'time': time};

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        title: map['title']?.toString() ?? '',
        time: map['time']?.toString() ?? '',
      );
}
