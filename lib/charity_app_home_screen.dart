import 'package:charity_project/bottom_navigation_view/view/bottom_bar_view.dart';
import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/events_list/events_list_screen.dart';
import 'package:charity_project/fond_list/fond_list_screen.dart';
import 'package:charity_project/models/tabIcon_data.dart';
import 'package:charity_project/models/user_data.dart';
import 'package:charity_project/my_profie/my_profile_screen.dart';
import 'package:flutter/material.dart';

class CharityAppHomeScreen extends StatefulWidget {
  const CharityAppHomeScreen({super.key, required this.userId});

  final int userId;

  @override
  _CharityAppHomeScreenState createState() => _CharityAppHomeScreenState();
}

class _CharityAppHomeScreenState extends State<CharityAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: CharityAppTheme.background,
  );

  @override
  void initState() {
    for (var tab in tabIconsList) {
      tab.isSelected = false;
    }
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    // Используйте переданные данные пользователя
    tabBody = MyProfileScreen(animationController: animationController, userId: widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CharityAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
            if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = MyProfileScreen(animationController: animationController, userId: widget.userId,);
                });
              });
            } else if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = EventsListScreen(animationController: animationController);
                });
              });
            } else if (index == 2) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = const FondListScreen();
                });
              });
            }
          },
        ),
      ],
    );
  }
}