import 'package:charity_project/charity_app_theme.dart';
import 'package:flutter/material.dart';


class UserProfileView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  final String photoUrl;
  final String firstName;
  final String lastName;
  final String role;

  const UserProfileView({
    super.key,
    this.animationController,
    this.animation,
    required this.photoUrl,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: CharityAppTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: CharityAppTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 25),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                          const SizedBox(width: 35),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: TextStyle(
                                  fontFamily: CharityAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                  letterSpacing: 1,
                                  color: CharityAppTheme.grey.withOpacity(0.5),
                                ),
                              ),
                              Text(
                                lastName,
                                style: TextStyle(
                                  fontFamily: CharityAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                  letterSpacing: 0.8,
                                  color: CharityAppTheme.grey.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 5), // Просто немного места добавил
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.green.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                role,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  color: Colors.green.withOpacity(0.5),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.green.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
