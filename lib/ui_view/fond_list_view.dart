import 'package:charity_project/fond_profile/fond_profile_screen.dart';
import 'package:charity_project/models/fond_data.dart';
import 'package:charity_project/ui_view/fond_profile_view.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:google_fonts/google_fonts.dart';

class FondListView extends StatefulWidget {
  const FondListView(
      {super.key, this.mainScreenAnimationController, this.mainScreenAnimation});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _FondListViewState createState() => _FondListViewState();
}

class _FondListViewState extends State<FondListView> with TickerProviderStateMixin {
  AnimationController? animationController;

  final donations = FondData.FondList;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 500,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 0, bottom: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: donations.length,
                itemBuilder: (BuildContext context, int index) {
                  final int count = donations.length;
                  final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();

                  final donation = donations[index];

                  return AnimatedDonationItem(
                    fond: donation,
                    fundName: donation.fundName,
                    donationAmount: double.parse(donation.amount),
                    animation: animation,
                    animationController: animationController!,
                    imageUrl: donation.imageUrl,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FondProfileScreen(
                            fond: donation,
                            animationController: animationController, // Pass the animation controller
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedDonationItem extends StatelessWidget {
  const AnimatedDonationItem({
    Key? key,
    required this.fundName,
    required this.donationAmount,
    required this.imageUrl,
    required this.onPressed,
    this.animationController,
    this.animation,
    required this.fond,
  }) : super(key: key);

  final String fundName;
  final double donationAmount;
  final String imageUrl;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback onPressed;
  final FondData fond;

  @override
  Widget build(BuildContext context) {
    TextStyle style = GoogleFonts.pacifico();

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: onPressed,
          child: FadeTransition(
            opacity: animation!,
            child: Transform(
              transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value),
                0.0,
                0.0,
              ),
              child: SizedBox(
                width: 150,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(3, 6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      children: [
                        Image.asset(
                          imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  fundName,
                                  style: style.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black.withOpacity(0.6),
                                        offset: const Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${donationAmount.toStringAsFixed(2)} руб',
                                  style: style.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black.withOpacity(0.6),
                                        offset: const Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
