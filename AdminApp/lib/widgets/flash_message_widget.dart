import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlashMessageWidget extends StatelessWidget {
  String errormsg;
  Color color;
  FlashMessageWidget(this.errormsg, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errormsg,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          child: ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
              child: SvgPicture.asset(
                "assets/images/bubbles.svg",
                height: 40,
                width: 40,
                color: color,
              ))),
      Positioned(
          top: -5,
          left: 0,
          child: Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/images/fail.svg"),
            Positioned(
              top: 30,
              child: SvgPicture.asset(
                "assets/images/close.svg",
                height: 16,
              ),
            )
          ]))
    ]);
  }
}
