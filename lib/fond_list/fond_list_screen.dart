import 'package:flutter/material.dart';
import 'package:charity_project/models/tag_data.dart';
import 'package:charity_project/events_list/view/running_view.dart';
import 'package:charity_project/fond_list/view/fond_list_view.dart';
import 'package:charity_project/charity_app_theme.dart';
import 'package:charity_project/models/fond_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FondListScreen extends StatefulWidget {
  const FondListScreen({Key? key});

  @override
  _FondListScreenState createState() => _FondListScreenState();
}

class _FondListScreenState extends State<FondListScreen> {
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<FondData> _allFonds = []; // Новый список для хранения всех фондов

  String _selectedTag = 'Выберите тег'; // Первый тег по умолчанию
  List<String> _tags = ['Выберите тег'];

  @override
  void initState() {
    super.initState();
    _fetchTags();

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
  }

  Future<void> _fetchTags() async {
    try {
      List<String> tags = await TagData.fetchTags();
      setState(() {
        _tags = ['Выберите тег', ...tags];
        _updateListByTag(_selectedTag); // Ensure list is updated after fetching tags
      });
    } catch (e) {
      print('Failed to load tags: $e');
    }
  }

  void _fetchFonds(String tag) async {
    final encodedTag = Uri.encodeComponent(tag);
    final response = await http.get(
      Uri.parse('http://192.168.0.112:3000/fonds${tag != 'Выберите тег' ? '?tag=$encodedTag' : ''}'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _allFonds = data.map((json) => FondData.fromJson(json)).toList();
        _updateListView(); // Update the list after fetching new data
        debugPrint('Fetched fonds: ${_allFonds.map((fond) => fond.fundName).toList()}');
      });
    } else {
      throw Exception('Failed to load fonds');
    }
  }

  void addAllListData(String tag) {
    // listViews.add(
    //   const RunningView(),
    // );

    listViews.add(
      Padding(
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
          items: _tags.map((String tag) {
            return DropdownMenuItem<String>(
              value: tag,
              child: Text(tag),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateListByTag(newValue);
            }
          },
        ),
      ),
    );

    listViews.add(
      FondListView(
        fondDataList: _allFonds,
        donation: false,
      ),
    );
  }

  void _updateListByTag(String tag) {
    setState(() {
      _selectedTag = tag;
    });
    _fetchFonds(tag);
  }

  void _updateListView() {
    print('Before clearing listViews: $listViews');
    setState(() {
      listViews.clear();
      addAllListData(_selectedTag);
    });
    print('After updating listViews: $listViews');
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
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            key: UniqueKey(), // Добавляем ключ, чтобы ListView перестраивался при изменении listViews
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top + 24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
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
        Container(
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
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 50 - 8.0 * topBarOpacity,
              bottom: 12 - 8.0 * topBarOpacity,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Список фондов',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: CharityAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        letterSpacing: 1.2,
                        color: CharityAppTheme.darkerText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}