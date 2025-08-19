import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_event_page.dart';
import '../models/event.dart';
import '../services/storage_service.dart';

// Windows 桌面需要 window_size
import 'package:window_size/window_size.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> _events = [];
  File? _bannerImage;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb && Platform.isWindows) {
      setWindowTitle('纪念日提醒');
      setWindowMinSize(const Size(500, 850));
      setWindowFrame(const Rect.fromLTWH(100, 100, 500, 850));
    }

    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await StorageService.loadEvents();
    setState(() {
      _events = events;
    });
  }

  Future<void> _saveEvents() async {
    await StorageService.saveEvents(_events);
  }

  void _addEvent(String name, DateTime date) {
    setState(() {
      _events.add(Event(name, date));
    });
    _saveEvents();
  }

  void _deleteEvent(int index) {
    final removed = _events[index];
    setState(() {
      _events.removeAt(index);
    });
    _saveEvents();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${removed.name} 已删除')));
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          '纪念日提醒',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 顶部 Banner
          GestureDetector(
            onTap: _pickBannerImage,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _bannerImage != null
                    ? Image.file(
                  _bannerImage!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/images/3.png',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 下方纪念日列表
          Expanded(
            child: _events.isEmpty
                ? const Center(
              child: Text(
                "还没有添加任何纪念日",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _events.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final event = _events[index];
                final daysLeft =
                    event.date.difference(DateTime.now()).inDays + 1;

                return Dismissible(
                  key: Key(event.name + event.date.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _deleteEvent(index),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: const Icon(Icons.event, color: Colors.white),
                      ),
                      title: Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '日期: ${event.date.year}-${event.date.month}-${event.date.day}\n剩余 $daysLeft 天',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEventPage(),
            ),
          );
          if (result != null && result is Map<String, dynamic>) {
            _addEvent(result['name'], result['date']);
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
