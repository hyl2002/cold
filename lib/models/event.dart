class Event {
  String name;
  DateTime date;
  Event(this.name, this.date);

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['name'],
      DateTime.parse(json['date']),
    );
  }
}
