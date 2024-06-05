import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/event_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventProfileView extends StatefulWidget {
  final EventData event;

  const EventProfileView({super.key, required this.event});

  @override
  _EventProfileViewState createState() => _EventProfileViewState();
}

class _EventProfileViewState extends State<EventProfileView> {
  late bool isNetworkImage;
  late bool isFondLogoNetworkImage;

  @override
  void initState() {
    super.initState();
    isNetworkImage = widget.event.imageUrl.startsWith('http') || widget.event.imageUrl.startsWith('https');
    isFondLogoNetworkImage = widget.event.ownerFondLogoUrl.startsWith('http') || widget.event.ownerFondLogoUrl.startsWith('https');
  }

  String getFormattedDate(String eventDate) {
    final eventDateTime = DateTime.parse(eventDate);
    final now = DateTime.now();
    final difference = eventDateTime.difference(now).inDays;

    if (difference == 1) {
      return 'Завтра';
    } else if (difference == 2) {
      return 'Послезавтра';
    } else if (difference > 2 && difference <= 4) {
      return 'Через $difference дня';
    } else {
      final DateFormat formatter = DateFormat('dd MMMM, EEEE', 'ru');
      return formatter.format(eventDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40.0),
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
                    widget.event.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    widget.event.imageUrl,
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
                      ? NetworkImage(widget.event.ownerFondLogoUrl)
                      : AssetImage(widget.event.ownerFondLogoUrl) as ImageProvider,
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
                'Дата начала: ${getFormattedDate(widget.event.data_start)}',
                style: const TextStyle(
                  fontFamily: CharityAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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