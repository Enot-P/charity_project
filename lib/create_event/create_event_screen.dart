import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  File? _eventImage;
  DateTime? _selectedDateTime;

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String description = _descriptionController.text;
      final String location = _locationController.text;
      final String date = _dateController.text;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: ID пользователя не найден')),
        );
        return;
      }

      var uri = Uri.parse('http://192.168.0.112:3000/create-event');
      var request = http.MultipartRequest('POST', uri)
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['location'] = location
        ..fields['date'] = date
        ..fields['user_id'] = userId.toString();

      if (_eventImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imageurl',
          _eventImage!.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ивент создан')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при создании ивента')),
        );
      }
    }
  }

  Future<void> _pickEventImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _eventImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Изменяем формат на YYYY-MM-DD
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать ивент'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickEventImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: _eventImage != null
                      ? Image.file(_eventImage!, fit: BoxFit.cover)
                      : const Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название ивента',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название ивента';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Описание ивента',
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите описание ивента';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Место проведения',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите место проведения';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Дата и время',
                ),
                readOnly: true,
                onTap: () => _selectDateTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, выберите дату и время';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}