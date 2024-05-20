import 'package:charity_project/fitness_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:charity_project/models/fond_data.dart';
import 'package:google_fonts/google_fonts.dart';

class FondProfileView extends StatefulWidget {
  final FondData? fond;

  const FondProfileView({
    super.key,
    this.fond,
  });

  @override
  _FondProfileViewState createState() => _FondProfileViewState();
}

class _FondProfileViewState extends State<FondProfileView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentFond = widget.fond;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: _animation,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0, 30 * (1.0 - _animation.value), 0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 25),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(currentFond!.imageUrl),
                          ),
                          const SizedBox(width: 35),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentFond.fundName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                  letterSpacing: 1,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                currentFond.tag,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  color: Colors.green.withOpacity(0.5),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.green.withOpacity(0.5),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 10)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade100,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 10.0,
                                  ),
                                  textStyle: GoogleFonts.caveat(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                                onPressed: () {
                                  // Add your logic here for what happens when the button is pressed
                                },

                                child: const Text('Пожертвовать'),
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
