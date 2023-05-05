import 'package:flutter/material.dart';

const double buttonSize = 70;

class LinearFlowWidget extends StatefulWidget {
  Function onPressed;
  LinearFlowWidget(this.onPressed, {super.key});

  @override
  State<LinearFlowWidget> createState() => _LinearFlowWidgetState();
}

class _LinearFlowWidgetState extends State<LinearFlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Flow(
        delegate: FlowMenuDelegate(controller: controller),
        children: <IconData>[
          Icons.exit_to_app,
        ].map<Widget>(buildItem).toList(),
      );
  Widget buildItem(IconData icon) => SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 252, 68, 60),
          splashColor: Colors.black,
          child: Icon(icon, color: Colors.white, size: 35),
          onPressed: () {
            if (icon == Icons.exit_to_app) {
              widget.onPressed();
            }
            if (controller.status == AnimationStatus.completed) {
              controller.reverse();
            } else {
              controller.forward();
            }
          },
        ),
      );
}

class FlowMenuDelegate extends FlowDelegate {
  final Animation<double> controller;
  const FlowMenuDelegate({required this.controller})
      : super(repaint: controller);
  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - buttonSize;
    final yStart = size.height - buttonSize;
    for (var i = 0; i < context.childCount; i++) {
      final childSize = context.getChildSize(i)!.width;
      final margin = 8;
      final dx = (childSize + margin) * i;
      final x = xStart;
      final y = yStart - dx * controller.value;
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
