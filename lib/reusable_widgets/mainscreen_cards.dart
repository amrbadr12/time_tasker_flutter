import 'package:flutter/material.dart';
import 'package:time_tasker/constants.dart';

class TaskDataReusableCard extends StatelessWidget {
  const TaskDataReusableCard(
      {Key key,
      @required this.mainText,
      @required this.subText,
      this.backgroundColor,
      this.mainTextColor,
      this.subTextColor,
      this.iconData,
      this.iconColor,
      this.optionalCirclePercent,
      this.iconContainerColor})
      : super(key: key);

  final String mainText;
  final String subText;
  final double optionalCirclePercent;
  final Color backgroundColor;
  final Color mainTextColor;
  final Color subTextColor;
  final IconData iconData;
  final Color iconColor;
  final Color iconContainerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: kMainDefaultHeightPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Card(
                    color: backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(iconData, size: 20, color: iconColor),
                    )),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    mainText,
                    softWrap: true,
                    style: kSubTitleTextStyle.copyWith(
                        fontSize: 30,
                        color: mainTextColor,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    subText,
                    softWrap: true,
                    style: kSubTitleTextStyle.copyWith(color: subTextColor,fontSize:14.0),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();
    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Colors.blue.shade700;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();
    ovalPath.moveTo(0.0, height + 0.2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}