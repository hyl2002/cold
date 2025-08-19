import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_event_page.dart';

// Windows 桌面需要 window_size
// 在 pubspec.yaml 中使用 window_size: ^0.1.0
// flutter pub get 后才能使用
// ignore: avoid_web_libraries_in_flutter
import 'package:window_size/window_size.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _events = [];
  File? _bannerImage;

  @override
  void initState() {
    super.initState();

    // 仅在 Windows 平台设置窗口大小
    if (!kIsWeb && Platform.isWindows) {
      setWindowTitle('纪念日提醒');
      setWindowMinSize(const Size(500, 850));
      setWindowFrame(const Rect.fromLTWH(100, 100, 500, 850));
    }
  }

  void _addEvent(String name, DateTime date) {
    setState(() {
      _events.add({
        'name': name,
        'date': date,
      });
    });
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
                final name = event['name'];
                final date = event['date'] as DateTime;
                final daysLeft =
                    date.difference(DateTime.now()).inDays+1;

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child:
                      const Icon(Icons.event, color: Colors.white),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '日期: ${date.year}-${date.month}-${date.day}\n剩余 $daysLeft 天',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing:
                    const Icon(Icons.arrow_forward_ios, size: 16),
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
