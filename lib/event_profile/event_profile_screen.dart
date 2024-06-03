import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/event_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventProfileScreen extends StatefulWidget {
  const EventProfileScreen({super.key, required this.event, this.animationController});
  final EventData event;
  final AnimationController? animationController;

  @override
  _EventProfileScreenState createState() => _EventProfileScreenState();
}

class _EventProfileScreenState extends State<EventProfileScreen> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.animationController != null) {
      topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: widget.animationController!,
          curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
        ),
      );
    } else {
      final defaultAnimationController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: defaultAnimationController,
          curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
        ),
      );

      defaultAnimationController.forward();
    }

    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            //topBarOpacity = scrollController.offset / 24);
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
  }

  void addAllListData() {
    listViews.add(
      EventProfileView(
        event: widget.event,
      ),
    );

    listViews.add(
      EventDescriptionView(
        event: widget.event,
      ),
    );
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
            ),
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
              top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 24,
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
          animation: widget.animationController ?? AnimationController(vsync: this),
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
                        color: CharityAppTheme.grey.withOpacity(0.4 * topBarOpacity),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
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
                          bottom: 12 - 8.0 * topBarOpacity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Text(
                                  widget.event.name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: CharityAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: CharityAppTheme.darkerText,
                                  ),
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
            );
          },
        ),
      ],
    );
  }
}

class EventProfileView extends StatelessWidget {
  final EventData event;

  String getFormattedDate(String eventDate) {
    final eventDateTime = DateTime.parse(eventDate);
    final now = DateTime.now();
    final difference = eventDateTime.difference(now).inDays;

    if (difference == 1) {
      return 'Завтра';
    } else if (difference == 2) {
      return 'Послезавтра';
    } else if (difference > 2 && difference <= 7) {
      return 'Через $difference дня';
    } else {
      final DateFormat formatter = DateFormat('dd MMMM, EEEE', 'ru');
      return formatter.format(eventDateTime);
    }
  }

  const EventProfileView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Определяем, является ли изображение локальным или сетевым
    final bool isNetworkImage = event.imageUrl.startsWith('http') || event.imageUrl.startsWith('https');
    final bool isFondLogoNetworkImage = event.ownerFondLogoUrl.startsWith('http') || event.ownerFondLogoUrl.startsWith('https');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
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
                  child: isNetworkImage
                      ? Image.network(
                    event.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    event.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: isFondLogoNetworkImage
                      ? NetworkImage(event.ownerFondLogoUrl)
                      : AssetImage(event.ownerFondLogoUrl) as ImageProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: CharityAppTheme.grey),
              const SizedBox(width: 8.0),
              Text(
                'Дата начала: ${getFormattedDate(event.data_start)}',
                style: const TextStyle(
                  fontFamily: CharityAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: CharityAppTheme.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventDescriptionView extends StatelessWidget {
  final EventData event;

  const EventDescriptionView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Описание',
            style: TextStyle(
              fontFamily: CharityAppTheme.fontName,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
              color: CharityAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            event.description,
            style: const TextStyle(
              fontFamily: CharityAppTheme.fontName,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.2,
              color: CharityAppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }
}