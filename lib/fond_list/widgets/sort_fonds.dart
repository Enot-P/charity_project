import 'package:flutter/material.dart';

class SortFonds extends StatefulWidget {
  final List<String> tags;
  final Function(String) onTagSelected;

  SortFonds({required this.tags, required this.onTagSelected});

  @override
  _SortFondsState createState() => _SortFondsState();
}

class _SortFondsState extends State<SortFonds> {
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    if (widget.tags.isNotEmpty) {
      _selectedTag = widget.tags[0];
    }
  }

  @override
  void didUpdateWidget(SortFonds oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags.isNotEmpty && _selectedTag == null) {
      setState(() {
        _selectedTag = widget.tags[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedTag,
        decoration: InputDecoration(
          labelText: 'Выберите тег',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        ),
        items: widget.tags.map((String tag) {
          return DropdownMenuItem<String>(
            value: tag,
            child: Text(tag),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedTag = newValue;
          });
          if (newValue != null) {
            widget.onTagSelected(newValue);
          }
        },
      ),
    );
  }
}