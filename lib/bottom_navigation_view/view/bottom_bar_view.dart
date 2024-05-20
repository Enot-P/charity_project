
import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/tabIcon_data.dart';
import 'package:flutter/material.dart';

import 'tab_icons.dart';
import 'tab_clipper.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({super.key, this.tabIconsList, this.changeIndex, this.addClick});

  final Function(int index)? changeIndex;
  final Function()? addClick;
  final List<TabIconData>? tabIconsList;

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController?.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, 0.0, 0.0),
              child: PhysicalShape(
                color: CharityAppTheme.white,
                // elevation: 16.0,
                clipper: TabClipper(
                    radius: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(
                        parent: animationController!,
                        curve: Curves.fastOutSlowIn))
                        .value * 38.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 62,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TabIcons(
                                tabIconData: widget.tabIconsList?[0],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList?[0]);
                                  widget.changeIndex!(0);
                                }),
                          ),
                          // Expanded(
                          //   child: TabIcons(
                          //       tabIconData: widget.tabIconsList?[1],
                          //       removeAllSelect: () {
                          //         setRemoveAllSelection(
                          //             widget.tabIconsList?[1]);
                          //         widget.changeIndex!(1);
                          //       }),
                          // ),
                          // SizedBox(
                          //   width: Tween<double>(begin: 0.0, end: 1.0)
                          //           .animate(CurvedAnimation(
                          //               parent: animationController!,
                          //               curve: Curves.fastOutSlowIn))
                          //           .value *
                          //       64.0,
                          // ),
                          // Expanded(
                          //   child: TabIcons(
                          //       tabIconData: widget.tabIconsList?[2],
                          //       removeAllSelect: () {
                          //         setRemoveAllSelection(
                          //             widget.tabIconsList?[2]);
                          //         widget.changeIndex!(2);
                          //       }),
                          // ),
                          Expanded(
                            child: TabIcons(
                                tabIconData: widget.tabIconsList?[3],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList?[3]);
                                  widget.changeIndex!(3);
                                }),
                          ),
                        ],
                      ),
                    ),
                    // ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        ),
      ],
    );
  }


  // этот метод используется для установки состояния выбранного значка
  // в нижнем навигационном меню, когда пользователь выбирает другой значок
  // или нажимает на кнопку "Добавить".
  void setRemoveAllSelection(TabIconData? tabIconData) {
    if (!mounted) return;
    setState(() {
      widget.tabIconsList?.forEach((TabIconData tab) {
        tab.isSelected = false;
        if (tabIconData!.index == tab.index) {
          tab.isSelected = true;
        }
      });
    });
  }
}
