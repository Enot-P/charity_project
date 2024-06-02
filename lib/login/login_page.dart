import 'dart:async';
import 'dart:convert';
import 'package:charity_project/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charity_project/charity_app_home_screen.dart';
import 'package:charity_project/login/common/custom_form_button.dart';
import 'package:charity_project/login/common/custom_input_field.dart';
import 'package:charity_project/login/common/page_header.dart';
import 'package:charity_project/login/common/page_heading.dart';
import 'package:charity_project/login/forget_password_page.dart';
import 'package:charity_project/login/signup_page.dart';
import 'package:email_validator/email_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(title: 'Вход'),
                        CustomInputField(
                          labelText: 'Email',
                          hintText: 'Ваш email',
                          controller: _emailController,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Введите email';
                            }
                            if (!EmailValidator.validate(textValue)) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          labelText: 'Пароль',
                          hintText: 'Ваш пароль',
                          obscureText: true,
                          suffixIcon: true,
                          controller: _passwordController,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Введите пароль';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const ForgetPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Забыли пароль?',
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomFormButton(
                          innerText: 'Вход',
                          onPressed: _handleLoginUser,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Нет аккаунта? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff939393),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Зарегистрируйтесь',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff748288),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );

      try {
        final response = await loginUser(email, password);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final Map<String, dynamic> userDataJson = responseBody['user'];
          final int userId = userDataJson['id_user'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CharityAppHomeScreen(userId: userId),
            ),
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Неправильный логин или пароль')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<http.Response> loginUser(String email, String password) async {
    // Логируем перед отправкой запроса
    debugPrint('Preparing to send login request to server');

    final response = await http.post(
      Uri.parse('http://192.168.0.112:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    // Логируем после получения ответа
    debugPrint('Request sent. Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    return response;
  }

}