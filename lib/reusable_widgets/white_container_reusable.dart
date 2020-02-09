import 'package:flutter/material.dart';

class WhiteReusableContainer extends StatelessWidget {
  final Widget containerChild;
  final double verticalMargin;
  final double horizontalMargin;
  WhiteReusableContainer({this.containerChild,this.verticalMargin,this.horizontalMargin});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left:horizontalMargin??0.0,top:verticalMargin??0.0,right:horizontalMargin??0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child:containerChild,
    );
  }
}