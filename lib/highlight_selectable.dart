library highlight_selectable;

import 'dart:async';

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
  final bool showLanguage;

  
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
    this.onChanged,
    this.showLanguage = false,
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
  bool _copyClicked = false;

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
    final ScrollController _scrollController = ScrollController();


    if (widget.showEditButton && _isEditing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: themeBg,
            child: Row(
              mainAxisAlignment: widget.showLanguage? MainAxisAlignment.spaceBetween:MainAxisAlignment.end,
              children: [
                if (widget.showLanguage)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Text(
                    widget.showLanguage && widget.language!="plaintext" ? widget.language?.toLowerCase() ?? 'plain text' : 'plain text',
                    style: TextStyle(
                      fontFamily: "monospace",
                      color: widget.theme[_rootKey]?.color ?? _defaultFontColor,
                      fontSize: widget.theme[_rootKey]?.fontSize ?? 14,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      color: widget.theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
                      child:IconButton(
                        icon: Icon(Icons.check, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
                        tooltip: 'Save',
                        onPressed: () {
                          setState(() => _isEditing = false);
                          widget.onChanged?.call(_controller.text);
                        },
                      ),
                    ),
                    Container(
                      color: widget.theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
                        tooltip: 'Cancel',
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _controller.text = widget.source;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ]
            )
          ),
          Container(
          color: themeBg,
          padding: widget.padding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64, minWidth: double.infinity),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: IgnorePointer(
                    ignoring: false,
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
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
                        overflow: TextOverflow.fade
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                )
              )
            ),
          ),
        )
       ]);
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
        Container(
          color: widget.theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
          child: IconButton(
            icon: Icon(_copyClicked? Icons.check: Icons.copy, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
            tooltip: 'Copy',
            onPressed: () {
              if (_copyClicked) return; // Prevent multiple clicks
              setState(() {
                _copyClicked = true;
              });
              Timer(const Duration(seconds: 2), () {
                setState(() {
                  _copyClicked = false;
                });
              });

              Clipboard.setData(ClipboardData(text: _controller.text));
              widget.onCopied?.call();
            },
          ),
        ),
      if (widget.showEditButton)
        Container(
          color: widget.theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
          child:IconButton(
            icon: Icon(Icons.edit, size: 16, color: widget.theme[_rootKey]?.color ?? _defaultFontColor),
            tooltip: 'Edit',
            onPressed: () {
              widget.onEdit?.call();
              setState(() => _isEditing = true);
            },
          ),
        ),
      ...?widget.overlayButtons,
    ];

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLanguage || widget.showCopyButton || widget.showEditButton || widget.overlayButtons != null || widget.overlayButtons?.isNotEmpty == true)
          Container(
            color: themeBg,
            child: Row(
              mainAxisAlignment: widget.showLanguage? MainAxisAlignment.spaceBetween:MainAxisAlignment.end,
              children: [
                if (widget.showLanguage)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Text(
                    widget.showLanguage && widget.language!="plaintext" ? widget.language?.toLowerCase() ?? 'plain text' : 'plain text',
                    style: TextStyle(
                      fontFamily: "monospace",
                      color: widget.theme[_rootKey]?.color ?? _defaultFontColor,
                      fontSize: widget.theme[_rootKey]?.fontSize ?? 14,
                    ),
                  ),
                ),
                if(widget.showCopyButton || widget.showEditButton || widget.overlayButtons != null || widget.overlayButtons?.isNotEmpty == true)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: buttons
                ),
              ]
            )
          ),
          Container(
            color: themeBg,
            padding: widget.padding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64, minWidth: double.infinity),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicWidth(
                    child: IgnorePointer(
                      ignoring: false,
                      child: widget.selectable
                          ? SelectableText.rich(
                              content,
                              textAlign: TextAlign.left,
                            )
                          : RichText(
                              text: content,
                              textAlign: TextAlign.left,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ]
    );
  }


}
