import 'package:flutter/material.dart';

const double buttonSize = 80;

class LinearFlowWidget extends StatefulWidget {
  const LinearFlowWidget({super.key});

  @override
  State<LinearFlowWidget> createState() => _LinearFlowWidgetState();
}

class _LinearFlowWidgetState extends State<LinearFlowWidget> {
  @override
  Widget build(BuildContext context) => Flow(
        delegate: FlowMenuDelegate(),
        children: <IconData>[
          Icons.exit_to_app,
        ].map<Widget>(buildItem).toList(),
      );
  Widget buildItem(IconData icon) => SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          elevation: 0,
          splashColor: Colors.black,
          child: Icon(icon, color: Colors.white, size: 45),
          onPressed: () {},
        ),
      );
}

class FlowMenuDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    for (var i = 0; i < context.childCount; i++) {
      final size = context.size;
      final xStart = size.width - buttonSize;
      final yStart = size.height - buttonSize;

      final childSize = context.getChildSize(i)!.width;
      final margin = 8;
      final dx = (childSize + margin) * i;
      final x = xStart - dx;
      final y = yStart;
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
