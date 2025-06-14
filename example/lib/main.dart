import 'package:flutter/material.dart';
import 'package:highlight_selectable/highlight_selectable.dart';
import 'package:highlight_selectable/theme_map.dart';

void main() {
  runApp(const HighlightDemoApp());
}

class HighlightDemoApp extends StatelessWidget {
  const HighlightDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Highlight Selectable Demo',
      theme: ThemeData.dark(),
      home: const HighlightHomePage(),
    );
  }
}

class HighlightHomePage extends StatefulWidget {
  const HighlightHomePage({super.key});

  @override
  State<HighlightHomePage> createState() => _HighlightHomePageState();
}

class _HighlightHomePageState extends State<HighlightHomePage> {
  bool _isSelectable = false;

  final String _code = '''
void main();
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlight Selectable Demo'),
        actions: [
          Row(
            children: [
              const Text("Selectable"),
              Switch(
                value: _isSelectable,
                onChanged: (value) {
                  setState(() {
                    _isSelectable = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HighlightSelectable(
          padding: const EdgeInsets.all(16.0),
        _code,
        language: 'dart',
        theme: themeMap['a11y-dark']!,
        selectable: _isSelectable,
        showCopyButton: true,
        showEditButton: true,
        onChanged: (updatedCode) {
          print("Edited code: $updatedCode");
        },
      ),
      ),
    );
  }
}
