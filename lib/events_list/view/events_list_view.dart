import 'package:charity_project/event_profile/event_profile_screen.dart';
import 'package:charity_project/models/event_data.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsListView extends StatefulWidget {
  const EventsListView(
      {super.key, this.mainScreenAnimationController, this.mainScreenAnimation});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _EventsListViewState createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> with TickerProviderStateMixin {
  AnimationController? animationController;
  late Future<List<EventData>> futureEvents;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    futureEvents = fetchEvents();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<List<EventData>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://192.168.0.112:3000/events'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((event) => EventData.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
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
              child: FutureBuilder<List<EventData>>(
                future: futureEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No events available'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 0, bottom: 16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final event = snapshot.data![index];
                        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animationController!,
                            curve: Interval((1 / snapshot.data!.length) * index, 1.0, curve: Curves.fastOutSlowIn),
                          ),
                        );
                        animationController?.forward();

                        return AnimatedEventItem(
                          event: event,
                          eventName: event.name,
                          eventDate: event.data_start,
                          animation: animation,
                          animationController: animationController!,
                          imageUrl: event.imageUrl,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventProfileScreen(
                                  event: event,
                                  animationController: animationController, // Pass the animation controller
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedEventItem extends StatelessWidget {
  const AnimatedEventItem({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.imageUrl,
    required this.onPressed,
    this.animationController,
    this.animation,
    required this.event,
  });

  final String eventName;
  final String eventDate;
  final String imageUrl;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback onPressed;
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
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0), // Уменьшенный вертикальный отступ
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0), // Уменьшенный радиус
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(3, 6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0), // Уменьшенный радиус
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 80, // Установленная высота
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
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
                        padding: const EdgeInsets.all(12.0), // Уменьшенный padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Уменьшенный размер шрифта
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4.0), // Уменьшенный отступ
                            Text(
                              getFormattedDate(eventDate),
                              style: style.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 14, // Уменьшенный размер шрифта
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
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
        );
      },
    );
  }
}