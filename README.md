# 📚 highlight_selectable

[![pub package](https://img.shields.io/pub/v/highlight_selectable.svg)](https://pub.dev/packages/highlight_selectable)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

A Flutter widget that displays syntax-highlighted code with optional selection, copy, and inline editing support — an enhanced version of [`flutter_highlight`](https://pub.dev/packages/flutter_highlight), made to feel more like ChatGPT or VSCode snippets.

---

## ✨ Features

- ✅ Syntax highlighting using [`highlight`](https://pub.dev/packages/highlight)
- ✅ Toggle between **selectable** or **read-only** code
- ✅ Optional **copy button**
- ✅ Built-in **edit mode** with save/cancel controls
- ✅ Support for **custom overlay buttons** (e.g. share, delete, etc.)
- ✅ All themes from `flutter_highlight` are supported
- ✅ Fully Flutter & web compatible (no `dart:io`)

---

## 📦 Installation

```yaml
dependencies:
  highlight_selectable: ^0.1.0
```


## Quick Start


```dart
import 'package:flutter/material.dart';
import 'package:highlight/themes/gruvbox-dark.dart';
import 'package:highlight_selectable/highlight_selectable.dart';

class Example extends StatelessWidget {
  final code = "print('Hello, world!');"

  @override
  Widget build(BuildContext context) {
    return HighlightSelectable(
      code,
      language: 'dart',
      theme: gruvboxDarkTheme,
      selectable: true,
      showCopyButton: true,
      showEditButton: true,
      onChanged: (newCode) => print('User updated the code:\n$newCode'),
      // onCopied: (){},
      // overlayButtons: List<Widget>[]
    );
  }
}
```
