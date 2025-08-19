import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class StorageService {
  static const String _key = 'events';

  static Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => Event.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final data = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }
}
