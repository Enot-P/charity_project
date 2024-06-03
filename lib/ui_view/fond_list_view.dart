import 'package:charity_project/fond_profile/fond_profile_screen.dart';
import 'package:charity_project/models/fond_data.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

class FondListView extends StatelessWidget {
  const FondListView({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    required this.donation,
    required this.fondDataList,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final bool donation;
  final List<FondData> fondDataList;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - mainScreenAnimation!.value), 0.0),
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
                itemCount: fondDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  final fond = fondDataList[index];
                  final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: mainScreenAnimationController!,
                      curve: Interval((1 / fondDataList.length) * index, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  );
                  mainScreenAnimationController?.forward();
                  return AnimatedDonationItem(
                    fond: fond,
                    fundName: fond.fundName,
                    donationAmount: donation ? fond.amount : null,
                    animation: animation,
                    animationController: mainScreenAnimationController!,
                    imageUrl: fond.imageUrl,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FondProfileScreen(
                            fond: fond,
                            animationController: mainScreenAnimationController, // Pass the animation controller
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
    super.key,
    required this.fundName,
    this.donationAmount,
    required this.imageUrl,
    required this.onPressed,
    this.animationController,
    this.animation,
    required this.fond,
  });

  final String fundName;
  final double? donationAmount;
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
                              if (donationAmount != null)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${donationAmount!.toStringAsFixed(2)} руб',
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