import 'dart:io';
import 'package:charity_project/login/common/custom_form_button.dart';
import 'package:charity_project/login/common/custom_input_field.dart';
import 'package:charity_project/login/common/page_header.dart';
import 'package:charity_project/login/common/page_heading.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Очистите контроллеры, когда они больше не нужны
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  File? _profileImage;

  final _signupFormKey = GlobalKey<FormState>();

  Future<void> registerUser(String name, String surname, String email, String password, File? profileImage) async {
    var uri = Uri.parse('http://localhost:3000/register');
    var request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['surname'] = surname
      ..fields['email'] = email
      ..fields['password'] = password;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        profileImage.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      // Обработка успешной регистрации
      // Например, перенаправление пользователя на страницу входа
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Обработка ошибки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.reasonPhrase}')),
      );
    }
  }

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _profileImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                const PageHeader(),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                  ),
                  child: Column(
                    children: [
                      const PageHeading(title: 'Регистрация',),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: _pickProfileImage,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      border: Border.all(color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_sharp,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        controller: _nameController,
                        labelText: 'Имя',
                        hintText: 'Ваше имя',
                        isDense: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Введите имя';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        controller: _surnameController,
                        labelText: 'Фамилия',
                        hintText: 'Ваша фамилия',
                        isDense: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Введите фамилию';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Ваш email',
                        isDense: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Введите email';
                          }
                          if (!EmailValidator.validate(textValue)) {
                            return 'Не существующий email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        controller: _passwordController,
                        labelText: 'Пароль',
                        hintText: 'Ваш пароль',
                        isDense: true,
                        obscureText: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                        suffixIcon: true,
                      ),
                      const SizedBox(height: 22,),
                      CustomFormButton(innerText: 'Зарегистрироваться', onPressed: _handleSignupUser,),
                      const SizedBox(height: 18,),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Уже есть аккаунт? ', style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()))
                              },
                              child: const Text('Войдите', style: TextStyle(fontSize: 15, color: Color(0xff748288), fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignupUser() {
    if (_signupFormKey.currentState!.validate()) {
      // Получение значений из полей ввода
      final name = _nameController.text;
      final surname = _surnameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // Показываем сообщение о начале отправки данных
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );

      // Вызов функции регистрации
      registerUser(name, surname, email, password, _profileImage);
    }
  }
}