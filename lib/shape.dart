import 'dart:ui';

import 'package:flutter/material.dart';

abstract class Shape {
  List<TouchPoints> pointsList = [];
  List<Offset> offsetPoints = [];
  double xPos = 0.0 ;
  double yPos = 0.0;
  double middlePointX = 0.0;
  double middlePointY = 0.0;
  var p1, p2;
  double height = 50;
  double width = 50;
  double midPoint=0.0;
  double scrollPos = 0;
  Paint paint = new Paint();
  bool rotate= false;
  bool alter = false;
  bool onFocus = false;

  double getHeight(){
    return height;
  }

  setHeight(double value) {
    height = height + value;
  }
  double getWidth(){
    return width;
  }
  setWidth(double value) {
    width = width+value;
  }

  void setPosition(details){
    this.xPos += details.delta.dx;
    this.yPos += details.delta.dy;
  }

  void setPaint(Color color){
    paint = Paint()
      ..color = color;
  }

  Paint getCurrentPaint(){
    if(onFocus){
      setPaint(Colors.red);
    }
    else{
      setPaint(Colors.black);
    }
    return paint;
  }

  getXMiddlePoint();
  getYMiddlePoint();
}
//Class to define a point touched at canvas
class TouchPoints{
  Paint paint;
  Offset points;
  TouchPoints({this.points, this.paint});
}

class FreeHandShape extends Shape{
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 10;
  FreeHandShape(Color color){
    //this.setPaint(Colors.white);
  }
  @override
  void setPosition(details){
    //Nothing yet
  }

  Paint getCurrentPaint(){
    if(onFocus){
      setPaint(Colors.red);
    }
    else{
      setPaint(Colors.grey[50]);
    }
    return Paint()
      ..strokeCap = strokeType
      ..isAntiAlias = true
      ..color = paint.color
      ..strokeWidth = strokeWidth;
  }

  @override
  getXMiddlePoint() {
    // TODO: implement getXMiddlePoint
    throw UnimplementedError();
  }

  @override
  getYMiddlePoint() {
    // TODO: implement getYMiddlePoint
    throw UnimplementedError();
  }
}

class RectShape extends Shape{
  RectShape(Color color){
    this.setPaint(color);
  }

  getMiddlePoint(){
    middlePointX = xPos + .5 * getHeight();
    middlePointY = yPos + .5 * getWidth();
  }
  getXMiddlePoint(){
    return middlePointX = xPos + .5 * getHeight();
  }

  getYMiddlePoint(){
    return middlePointY = yPos + .5 * getWidth();
  }

}

class LineShape extends Shape{
  double distance = 100;

  LineShape(Color color){
    this.setPaint(color);
  }

  p1X(){
    return this.xPos;
  }
  p2X(){
    return (this.xPos + this.getHeight());
  }
  p1Y(){
    return this.yPos;
  }
  p2Y(){
    return (this.yPos + this.getHeight());
  }


  getP1(){return Offset(p1X(), p1Y());}
  getP2(){return Offset(p2X(), p2Y());}

  getXMiddlePoint(){
    return middlePointX = (p1X() + p2X())/2;
  }

  getYMiddlePoint(){
    return middlePointY = (p2Y() + p2Y())/2;
  }
}

class CircleShape extends Shape{
  double distance = 50;
  // canvas.drawLine(p1, p2, paint);

  CircleShape(Color color){
    this.setPaint(color);
  }
  @override
  void setPosition(details){
    this.xPos += details.delta.dx;
    this.yPos += details.delta.dy;
  }

  getCenter(){
    return Offset(this.xPos, this.yPos);
  }

  @override
  getXMiddlePoint() {
    // TODO: implement getXMiddlePoint
    throw UnimplementedError();
  }

  @override
  getYMiddlePoint() {
    // TODO: implement getYMiddlePoint
    throw UnimplementedError();
  }
}