import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/event_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              fontSize: 22,
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
              fontSize: 15,
              letterSpacing: 0.2,
              color: CharityAppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }
}