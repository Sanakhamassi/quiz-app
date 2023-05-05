import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlashMessageWidget extends StatelessWidget {
  const FlashMessageWidget({
    Key? key,
    required this.errormsg,
  }) : super(key: key);
  final String errormsg;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: const BoxDecoration(
            color: Color(0xFFC72C41),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Oh snap",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    errormsg,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                color: Color(0xFF801336),
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
