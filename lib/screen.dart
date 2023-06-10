import 'package:flutter/material.dart';
import 'package:maps_example/yandex_map_page.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

List<String> points = [];

class _FirstScreenState extends State<FirstScreen> {
  late final result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('List of Points')),
        backgroundColor: Colors.deepPurple,
        body: Column(children: [
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: points.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(points[index], style: TextStyle(fontSize: 22));
                }),
          ),
          FloatingActionButton(
            onPressed: () async {
              // ignore: unused_local_variable
              final value = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return YandexMapPage();
                }),
              );
              setState(() {});
            },
            child: Text('+'),
          )
        ]));
  }
}
