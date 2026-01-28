import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/calendar_provider.dart';
import '../models/event.dart';
import '../models/jalali_date.dart';
import '../services/date_conversion_service.dart';
import '../utils/calendar_utils.dart';

class AddEventScreen extends StatefulWidget {
  final JalaliDate? selectedDate;
  final Event? event;

  const AddEventScreen({Key? key, this.selectedDate, this.event}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _selectedDateTime;
  String _selectedCategory = 'personal';
  bool _hasReminder = false;
  DateTime? _reminderTime;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedDateTime = widget.event!.date;
      _selectedCategory = widget.event!.category;
      _hasReminder = widget.event!.hasReminder;
      _reminderTime = widget.event!.reminderTime;
      _selectedColor = Color(int.parse(widget.event!.color.replaceFirst('#', '0xFF')));
    } else if (widget.selectedDate != null) {
      _selectedDateTime = DateConversionService.jalaliToGregorian(widget.selectedDate!);
    } else {
      _selectedDateTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'ویرایش رویداد' : 'افزودن رویداد'),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildDateTimeSelector(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildReminderSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان رویداد',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'لطفا عنوان رویداد را وارد کنید';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'توضیحات (اختیاری)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final jalaliDate = JalaliDate.fromGregorian(_selectedDateTime);
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('تاریخ و زمان'),
        subtitle: Text(
          '${CalendarUtils.toPersianNumber(jalaliDate.day)} ${jalaliDate.getMonthName()} ${CalendarUtils.toPersianNumber(jalaliDate.year)} - ${CalendarUtils.toPersianNumber(_selectedDateTime.hour)}:${CalendarUtils.toPersianNumber(_selectedDateTime.minute.toString().padLeft(2, '0'))}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _selectDateTime,
      ),
    );
  }

  Widget _buildCategorySelector() {
    const categories = {
      'personal': 'شخصی',
      'work': 'کاری',
      'family': 'خانوادگی',
      'health': 'سلامت',
      'education': 'آموزشی',
      'other': 'سایر',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'دستهبندی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _selectedCategory == entry.key,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = entry.key;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _selectedColor,
          radius: 12,
        ),
        title: const Text('رنگ رویداد'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _selectColor,
      ),
    );
  }

  Widget _buildReminderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('یادآوری'),
              subtitle: const Text('دریافت اعلان برای این رویداد'),
              value: _hasReminder,
              onChanged: (value) {
                setState(() {
                  _hasReminder = value;
                  if (value && _reminderTime == null) {
                    _reminderTime = _selectedDateTime.subtract(const Duration(hours: 1));
                  }
                });
              },
            ),
            if (_hasReminder) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('زمان یادآوری'),
                subtitle: Text(
                  _reminderTime != null
                      ? '${CalendarUtils.toPersianNumber(_reminderTime!.hour)}:${CalendarUtils.toPersianNumber(_reminderTime!.minute.toString().padLeft(2, '0'))}'
                      : 'انتخاب نشده',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectReminderTime,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveEvent,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        widget.event != null ? 'ویرایش رویداد' : 'ذخیره رویداد',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectColor() async {
    Color? color = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('انتخاب رنگ'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempColor),
              child: const Text('تایید'),
            ),
          ],
        );
      },
    );
    
    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null 
          ? TimeOfDay.fromDateTime(_reminderTime!) 
          : TimeOfDay.fromDateTime(_selectedDateTime.subtract(const Duration(hours: 1))),
    );
    
    if (time != null) {
      setState(() {
        _reminderTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDateTime,
        category: _selectedCategory,
        hasReminder: _hasReminder,
        reminderTime: _reminderTime,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );

      final provider = Provider.of<CalendarProvider>(context, listen: false);
      if (widget.event != null) {
        provider.updateEvent(event);
      } else {
        provider.addEvent(event);
      }

      Navigator.pop(context);
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف رویداد'),
        content: const Text('آیا مطمئن هستید که میخواهید این رویداد را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<CalendarProvider>(context, listen: false);
              provider.deleteEvent(widget.event!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}