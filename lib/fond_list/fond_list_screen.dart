import 'package:charity_project/models/tag_data.dart';
import 'package:charity_project/ui_view/fond_list_view.dart';
import 'package:charity_project/ui_view/running_view.dart';
import 'package:charity_project/ui_view/title_view.dart';

import 'package:flutter/material.dart';

import '../charity_app_theme.dart';


class FondListScreen extends StatefulWidget {
  const FondListScreen({Key? key, this.animationController});

  final AnimationController? animationController;
  @override
  _FondListScreenState createState() => _FondListScreenState();
}

class _FondListScreenState extends State<FondListScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String _selectedTag = TagData.tags[0]; // Первый тег по умолчанию
  final List<String> _tags = TagData.getTags();

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData(_selectedTag);

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

  void addAllListData(String tag) {
    const int animationDuration = 5;

    listViews.add(
      RunningView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / animationDuration) * 3, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      TitleView(
        titleTxt: 'Список фондов',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / animationDuration) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      FondListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: const Interval((1 / animationDuration) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );
  }

  void _updateListByTag(String tag) {
    setState(() {
      listViews.clear();
      addAllListData(tag);
    });
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
              height: MediaQuery
                  .of(context)
                  .padding
                  .bottom,
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
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery
                      .of(context)
                      .padding
                      .top + 24,
              bottom: 62 + MediaQuery
                  .of(context)
                  .padding
                  .bottom,
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
                  0.0,
                  30 * (1.0 - topBarAnimation!.value),
                  0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: CharityAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: CharityAppTheme.grey.withOpacity(
                            0.4 * topBarOpacity),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 50 - 8.0 * topBarOpacity,
                      bottom: 12 - 8.0 * topBarOpacity,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Список фондов',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: CharityAppTheme.fontName,
                                fontWeight: FontWeight.w700,
                                fontSize: 15 + 6 - 6 * topBarOpacity,
                                letterSpacing: 1.2,
                                color: CharityAppTheme.darkerText,
                              ),
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedTag,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTag = newValue!;
                              _updateListByTag(newValue);
                            });
                          },
                          items: _tags.map<DropdownMenuItem<String>>((
                              String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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
