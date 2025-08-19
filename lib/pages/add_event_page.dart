import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;

  void _saveEvent() {
    if (_nameController.text.isNotEmpty && _selectedDate != null) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'date': _selectedDate,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入事件名称并选择日期')),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime now =DateTime.now();
    final DateTime today=DateTime(now.year,now.month,now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        // 自定义日历样式（阴影 & 圆角）
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade400, // 选中日期高亮色
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(5, 8),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildShadowCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('添加纪念日'),
        elevation: 6,
        shadowColor: Colors.black54,
        backgroundColor: Colors.blue.shade400,
        actions: [
          IconButton(
            onPressed: _saveEvent,
            icon: const Icon(Icons.check, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShadowCard(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '事件名称',
                  border: InputBorder.none,
                ),
              ),
            ),
            _buildShadowCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? '未选择日期'
                          : '选择的日期: ${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      shadowColor: Colors.black.withOpacity(0.4),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _pickDate,
                    child: const Text('选择日期'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
