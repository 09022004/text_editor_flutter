import 'package:flutter/material.dart';

void main() {
  runApp(const TextEditorApp());
}

class TextEditorApp extends StatelessWidget {
  const TextEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TextEditorCanvas(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TextEditorCanvas extends StatefulWidget {
  const TextEditorCanvas({super.key});

  @override
  State<TextEditorCanvas> createState() => _TextEditorCanvasState();
}

class _TextEditorCanvasState extends State<TextEditorCanvas> {
  List<TextItem> texts = [];
  TextItem? selectedTextItem;

  final List<String> fontFamilies = [
    'Roboto',
    'Lobster',
    'Montserrat',
    'Malibu',
    'Toffee',
  ];

  @override
  void initState() {
    super.initState();
    var defaultText = TextItem(text: "Type here", x: 50, y: 50);
    texts.add(defaultText);
    selectedTextItem = defaultText;
  }

  void addText() {
    setState(() {
      var newText = TextItem(text: "New Text", x: 50, y: 50);
      texts.add(newText);
      selectedTextItem = newText;
    });
  }

  void updateText(TextItem oldItem, TextItem newItem) {
    setState(() {
      int index = texts.indexOf(oldItem);
      if (index != -1) {
        texts[index] = newItem;
      }
    });
  }

  void selectText(TextItem item) {
    setState(() {
      selectedTextItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Text Editor",
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addText,
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedTextItem != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedTextItem!.fontFamily,
                    items: fontFamilies
                        .map((font) => DropdownMenuItem(
                              value: font,
                              child: Text(
                                font,
                                style: TextStyle(fontFamily: font),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTextItem!.fontFamily = value!;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: () {
                      setState(() {
                        selectedTextItem!.fontWeight =
                            selectedTextItem!.fontWeight == FontWeight.bold
                                ? FontWeight.normal
                                : FontWeight.bold;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: () {
                      setState(() {
                        selectedTextItem!.fontStyle =
                            selectedTextItem!.fontStyle == FontStyle.italic
                                ? FontStyle.normal
                                : FontStyle.italic;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underline),
                    onPressed: () {
                      setState(() {
                        selectedTextItem!.decoration =
                            selectedTextItem!.decoration == TextDecoration.underline
                                ? TextDecoration.none
                                : TextDecoration.underline;
                      });
                    },
                  ),
                  Slider(
                    value: selectedTextItem!.fontSize,
                    min: 10,
                    max: 50,
                    divisions: 8,
                    label: selectedTextItem!.fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedTextItem!.fontSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                for (var textItem in texts)
                  DraggableEditableText(
                    key: ValueKey(textItem),
                    item: textItem,
                    isSelected: textItem == selectedTextItem,
                    onSelect: selectText,
                    onUpdate: (newItem) => updateText(textItem, newItem),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextItem {
  String text;
  double x;
  double y;
  String fontFamily;
  double fontSize;
  FontWeight fontWeight;
  FontStyle fontStyle;
  TextDecoration decoration;

  TextItem({
    required this.text,
    required this.x,
    required this.y,
    this.fontFamily = 'Roboto',
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.decoration = TextDecoration.none,
  });

  TextItem copyWith({
    String? text,
    double? x,
    double? y,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextItem(
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      decoration: decoration ?? this.decoration,
    );
  }
}

class DraggableEditableText extends StatefulWidget {
  final TextItem item;
  final bool isSelected;
  final Function(TextItem) onSelect;
  final Function(TextItem) onUpdate;

  const DraggableEditableText({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
  });

  @override
  State<DraggableEditableText> createState() => _DraggableEditableTextState();
}

class _DraggableEditableTextState extends State<DraggableEditableText> {
  late TextEditingController controller;
  late double x;
  late double y;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.item.text);
    x = widget.item.x;
    y = widget.item.y;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => widget.onSelect(widget.item),
        onPanUpdate: (details) {
          setState(() {
            x += details.delta.dx;
            y += details.delta.dy;
          });
        },
        onPanEnd: (details) {
          widget.onUpdate(widget.item.copyWith(text: controller.text, x: x, y: y));
        },
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: widget.isSelected ? Colors.blue : Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: widget.item.fontSize,
              fontWeight: widget.item.fontWeight,
              fontStyle: widget.item.fontStyle,
              decoration: widget.item.decoration,
              fontFamily: widget.item.fontFamily,
            ),
            onChanged: (value) {
              widget.onUpdate(widget.item.copyWith(text: value, x: x, y: y));
            },
          ),
        ),
      ),
    );
  }
}
