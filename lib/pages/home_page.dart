import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_event_page.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
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

  void _editEvent(int index, Event updatedEvent) {
    setState(() {
      _events[index] = updatedEvent;
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
                  'assets/images/校历.jpg',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 事件网格显示
          Expanded(
            child: _events.isEmpty
                ? const Center(
              child: Text(
                "还没有添加任何纪念日",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                itemCount: _events.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 每行三个
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1, // 正方形
                ),
                itemBuilder: (context, index) {
                  final event = _events[index];
                  final daysLeft =
                      event.date.difference(DateTime.now()).inDays + 1;

                  return Stack(
                    children: [
                      // 中间点击编辑
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEventPage(
                                initialName: event.name,
                                initialDate: event.date,
                              ),
                            ),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            _editEvent(
                              index,
                              Event(result['name'], result['date']),
                            );
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black38,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '剩余 $daysLeft 天',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${event.date.year}-${event.date.month}-${event.date.day}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 删除按钮右上角
                      Positioned(
                        top: 4,
                        right: 4,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteEvent(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
