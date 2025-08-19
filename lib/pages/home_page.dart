import 'package:flutter/material.dart';
import 'add_event_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _events = [];

  void _addEvent(String name, DateTime date) {
    setState(() {
      _events.add({
        'name': name,
        'date': date,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 浅灰背景
      appBar: AppBar(
        elevation: 4, // 阴影
        backgroundColor: Colors.blueAccent,
        title: const Text(
          '纪念日提醒',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _events.isEmpty
          ? const Center(
        child: Text(
          "还没有添加任何纪念日",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final event = _events[index];
          final name = event['name'];
          final date = event['date'] as DateTime;
          final daysLeft = date.difference(DateTime.now()).inDays;

          return Card(
            elevation: 6, // 阴影效果
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.event, color: Colors.white),
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
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
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
