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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  File? _profileImage;

  final _signupFormKey = GlobalKey<FormState>();

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

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
                          labelText: 'Имя',
                          hintText: 'Ваше имя',
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                          labelText: 'Фамилия',
                          hintText: 'Ваша фамилия',
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Введите фамилию';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                          labelText: 'Email',
                          hintText: 'Ваш email',
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Введите email';
                            }
                            if(!EmailValidator.validate(textValue)) {
                              return 'Не существующий email';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        labelText: 'Пароль',
                        hintText: 'Ваш пароль',
                        isDense: true,
                        obscureText: true,
                        validator: (textValue) {
                          if(textValue == null || textValue.isEmpty) {
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
    // signup user
    if (_signupFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );
    }
  }
}
