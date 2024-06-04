import 'dart:convert';
import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/fond_data.dart';
import 'package:charity_project/models/user_data.dart';
import 'package:charity_project/fond_list/view/fond_list_view.dart';
import 'package:charity_project/my_profie/view/donation_list_view.dart';
import 'package:charity_project/my_profie/view/user_profile_view.dart';
import 'package:charity_project/ui_view/title_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key, this.animationController, required this.userId});

  final AnimationController? animationController;
  final int userId;

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  UserData? userData;
  List<FondData> lastDonations = [];


  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    fetchUserData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  Future<void> fetchUserData() async {
    final userResponse = await http.get(Uri.parse('http://192.168.0.112:3000/user/${widget.userId}'));
    final donationsResponse = await http.get(Uri.parse('http://192.168.0.112:3000/user/${widget.userId}/last-donations'));

    if (userResponse.statusCode == 200 && donationsResponse.statusCode == 200) {
      setState(() {
        userData = UserData.fromJson(jsonDecode(userResponse.body));
        lastDonations = (jsonDecode(donationsResponse.body) as List)
            .map((data) => FondData.fromJson(data))
            .toList();
        addAllListData();
      });
    } else {
      // Обработка ошибки
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  void addAllListData() {
    const int animationDuration = 5;

    if (userData != null) {
      listViews.add(
        UserProfileView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve: const Interval((1 / animationDuration) * 1, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          userData: userData!,
        ),
      );
      listViews.add(
        TitleView(
          titleTxt: 'Ваши последние пожертвования:',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve: const Interval((1 / animationDuration) * 2, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
        ),
      );

      listViews.add(
        FondListView(donation: true, fondDataList: lastDonations)
      );
    }
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CharityAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData || userData == null) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: CharityAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: CharityAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Профиль',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: CharityAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: CharityAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}