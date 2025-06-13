library highlight_selectable;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

class HighlightSelectable extends StatefulWidget  {
  final String source;
  final String? language;
  final Map<String, TextStyle> theme;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool selectable;
  final ValueChanged<String>? onChanged;

  
  final bool showCopyButton;
  final bool showEditButton;
  final List<Widget>? overlayButtons;
  final VoidCallback? onEdit;
  final VoidCallback? onCopied;

  const HighlightSelectable(
    this.source, {super.key, 
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    this.selectable = false,
    this.overlayButtons,
    this.showCopyButton = false,
    this.showEditButton = false,
    this.onCopied,
    this.onEdit,
    this.onChanged
  });

  @override
  State<HighlightSelectable> createState() => HighlightSelectableState();
}

class HighlightSelectableState extends State<HighlightSelectable>{
  static const _rootKey = 'root';
  static const _defaultFontFamily = 'monospace';
  static const _defaultFontColor = Color(0xff000000);
  static const _defaultBackgroundColor = Color(0xffffffff);
  late TextEditingController _controller;
  bool _isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.source);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    void _traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(
          node.className == null
              ? TextSpan(text: node.value)
              : TextSpan(text: node.value, style: widget.theme[node.className!]),
        );
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(TextSpan(children: tmp, style: widget.theme[node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;

        for (var child in node.children!) {
          _traverse(child);
          if (child == node.children!.last) {
            currentSpans = stack.isNotEmpty ? stack.removeLast() : spans;
          }
        }
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = widget.theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor;

    if (widget.showEditButton && _isEditing) {
      return Container(
        color: themeBg,
        padding: widget.padding,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120), // adjust to your desired min height
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                focusNode: _focusNode,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.theme[_rootKey]?.fontSize ?? 14,
                  height: widget.theme[_rootKey]?.height ?? 1.2,
                  letterSpacing: widget.theme[_rootKey]?.letterSpacing ?? 0.5,
                  wordSpacing: widget.theme[_rootKey]?.wordSpacing ?? 0.5,
                  fontWeight: widget.theme[_rootKey]?.fontWeight ?? FontWeight.normal,
                  fontStyle: widget.theme[_rootKey]?.fontStyle ?? FontStyle.normal,
                  color: widget.theme[_rootKey]?.color ?? _defaultFontColor,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.check, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
                    tooltip: 'Save',
                    onPressed: () {
                      setState(() => _isEditing = false);
                      widget.onChanged?.call(_controller.text);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
                    tooltip: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _controller.text = widget.source;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    final parsed = highlight.parse(_controller.text, language: widget.language).nodes!;
    final defaultStyle = TextStyle(
      fontFamily: _defaultFontFamily,
      color: widget.theme[_rootKey]?.color ?? _defaultFontColor,
    ).merge(widget.textStyle);

    final content = TextSpan(
      style: defaultStyle,
      children: _convert(parsed),
    );

    final buttons = <Widget>[
      if (widget.showCopyButton)
        IconButton(
          icon: Icon(Icons.copy, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
          tooltip: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text));
            widget.onCopied?.call();
          },
        ),
      if (widget.showEditButton)
        IconButton(
          icon: Icon(Icons.edit, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
          tooltip: 'Edit',
          onPressed: () {
            FocusScope.of(context).requestFocus(_focusNode);
            widget.onEdit?.call();
            setState(() => _isEditing = true);
          },
        ),
      ...?widget.overlayButtons,
    ];

    return Container(
      color: themeBg,
      padding: widget.padding,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.selectable
                ? SelectableText.rich(content)
                : RichText(text: content),
          ),
          if (buttons.isNotEmpty)
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: buttons,
              ),
            ),
        ],
      ),
    );
  }


}
