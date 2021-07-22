import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(CanvasPainting());

class CanvasPainting extends StatefulWidget {
  @override
  _CanvasPaintingState createState() => _CanvasPaintingState();
}

abstract class Shape {
  double xPos = 0.0 ;
  double yPos = 0.0;
  Paint paint = new Paint();
  var p1, p2;

  void setPosition(details);

  void setPaint(Color color){
    paint = Paint()
      ..color = color;
  }
}

class RectShape extends Shape{
  RectShape(Color color){
    this.setPaint(color);
  }
  @override
  void setPosition(details){
    this.xPos += details.delta.dx;
    this.yPos += details.delta.dy;
  }

}

class LineShape extends Shape{
  double distance = 100;
  // canvas.drawLine(p1, p2, paint);

  LineShape(Color color){
    this.setPaint(color);
    p1 = Offset(50, 50);
    p2 = Offset(250, 250);
  }
  @override
  void setPosition(details){
    this.xPos += details.delta.dx;
    this.yPos += details.delta.dy;
    p1 = Offset(this.xPos, this.yPos);
    p2 = Offset(this.xPos + this.distance, this.yPos + this.distance);
  }
}

class CircleShape extends Shape{
  double distance = 50;
  // canvas.drawLine(p1, p2, paint);

  CircleShape(Color color){
    this.setPaint(color);
    p1 = Offset(1050, 1050);
  }
  @override
  void setPosition(details){
    this.xPos += details.delta.dx;
    this.yPos += details.delta.dy;
    p1 = Offset(this.xPos, this.yPos);
  }
}

class _CanvasPaintingState extends State<CanvasPainting> {
    GlobalKey globalKey = GlobalKey();
    List<TouchPoints> points = List();
    double opacity = 1.0;
    StrokeCap strokeType = StrokeCap.round;
    double strokeWidth = 3.0;
    Color selectedColor = Colors.black;
    List<Shape> shape =[];

    List<double> xPosList = [0.0];
    List<double>  yPosList = [0.0];
    final width = 100.0;
    final height = 100.0;
    bool _dragging = false;
    var index = 0;

    bool _insideRect(double x, double y) {
      var xPos,yPos;
      for(int i= 0; i < shape.length; i++){
        if (x >= shape[i].xPos && x <= shape[i].xPos + width && y >= shape[i].yPos && y <= shape[i].yPos + height) {
          index = i;
          return true;
        }
      }
      return false;
    }
    Future<void> _pickStroke() async {
      //Shows AlertDialog
      return showDialog<void>(
        context: context,

        //Dismiss alert dialog when set true
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          //Clips its child in a oval shape
          return ClipOval(
            child: AlertDialog(
              //Creates three buttons to pick stroke value.
              actions: <Widget>[
                //Resetting to default stroke value
                FlatButton(
                  child: Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    strokeWidth = 3.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 24,
                  ),
                  onPressed: () {
                    strokeWidth = 10.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 40,
                  ),
                  onPressed: () {
                    strokeWidth = 30.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 60,
                  ),
                  onPressed: () {
                    strokeWidth = 50.0;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    Future<void> _opacity() async {
      //Shows AlertDialog
      return showDialog<void>(
        context: context,

        //Dismiss alert dialog when set true
        barrierDismissible: true,

        builder: (BuildContext context) {
          //Clips its child in a oval shape
          return ClipOval(
            child: AlertDialog(
              //Creates three buttons to pick opacity value.
              actions: <Widget>[
                FlatButton(
                  child: Icon(
                    Icons.opacity,
                    size: 24,
                  ),
                  onPressed: () {
                    //most transparent
                    opacity = 0.1;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.opacity,
                    size: 40,
                  ),
                  onPressed: () {
                    opacity = 0.5;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.opacity,
                    size: 60,
                  ),
                  onPressed: () {
                    //not transparent at all.
                    opacity = 1.0;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    Future<void> _save() async {
      RenderRepaintBoundary boundary =
      globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      //Request permissions if not already granted
      if (!(await Permission.storage.status.isGranted))
        await Permission.storage.request();

      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 60,
          name: "canvas_image");
      print(result);
    }
    List<Widget> fabOption() {
      return <Widget>[
        FloatingActionButton(
          heroTag: "paint_save",
          child: Icon(Icons.save),
          tooltip: 'Save',
          onPressed: () {
            //min: 0, max: 50
            setState(() {
              _save();
            });
          },
        ),
        FloatingActionButton(
          heroTag: "paint_stroke",
          child: Icon(Icons.arrow_right_alt_outlined),
          tooltip: 'Stroke',
          onPressed: () {
            //min: 0, max: 50
            setState(() {
              _pickStroke();
              shape.add(new LineShape(this.selectedColor));
            });
          },
        ),
        FloatingActionButton(
          heroTag: "paint_opacity",
          child: Icon(Icons.web_asset_outlined),
          tooltip: 'Opacity',
          onPressed: () {
            //min:0, max:1
            setState(() {
              _opacity();
              shape.add(new RectShape(this.selectedColor));
              //index++;
              // xPosList.add(0.0);
              // yPosList.add(0.0);
            });
          },
        ),
        FloatingActionButton(
            heroTag: "circle",
            child: Icon(Icons.adjust_rounded),
            tooltip: "Circle",
            onPressed: () {
              setState(() {
                shape.add(new CircleShape(this.selectedColor));
                //points.clear();
              });
            }),
        FloatingActionButton(
            heroTag: "erase",
            child: Icon(Icons.clear),
            tooltip: "Erase",
            onPressed: () {
              setState(() {
                shape.removeLast();
                //points.clear();
              });
            }),

        FloatingActionButton(
          backgroundColor: Colors.white,
          heroTag: "color_green",
          child: colorMenuItem(Colors.green),
          tooltip: 'Color',
          onPressed: () {
            setState(() {
              selectedColor = Colors.green;
            });
          },
        ),
        FloatingActionButton(
          backgroundColor: Colors.white,
          heroTag: "color_pink",
          child: colorMenuItem(Colors.pink),
          tooltip: 'Color',
          onPressed: () {
            setState(() {
              selectedColor = Colors.pink;
            });
          },
        ),
        FloatingActionButton(
          backgroundColor: Colors.white,
          heroTag: "color_blue",
          child: colorMenuItem(Colors.blue),
          tooltip: 'Color',
          onPressed: () {
            setState(() {
              selectedColor = Colors.blue;
            });
          },
        ),
      ];
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: GestureDetector(
            onPanUpdate: (details) {
              //if (_dragging) {
                setState(() {
                  //if(shape[index] is RectShape){
                    shape.last.setPosition(details);
                  //}
                  //shape[index].setPosition(details);
                });
              //}
            },
            onPanStart: (details) {
              //_dragging = _insideRect(details.globalPosition.dx,details.globalPosition.dy,);
            },

            onPanEnd: (details) {
              _dragging = false;
            },
            child: RepaintBoundary(
              key: globalKey,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Image.asset("assets/images/hut.png"),
                  ),
                  CustomPaint(
                    size: Size.infinite,
                    painter: MyPainter(
                        width: width,
                        height: height,
                        selectedColor: this.selectedColor,
                        index: this.index,
                        shapes: this.shape
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: AnimatedFloatingActionButton(
            fabButtons: fabOption(),
            colorStartAnimation: Colors.blue,
            colorEndAnimation: Colors.cyan,
            animatedIconData: AnimatedIcons.menu_close,
          ),
        ),
      );
    }

    Widget colorMenuItem(Color color) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = color;
          });
        },
        child: ClipOval(
          child: Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            height: 36,
            width: 36,
            color: color,
          ),
        ),
      );
    }
}

class MyPainter extends CustomPainter {
  MyPainter({this.width, this.height, this.index, this.selectedColor,this.shapes});
  Paint painting = new Paint();

  Color selectedColor;
  //Keep track of the points tapped on the screen
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = List();
  List<Shape> shapes = [];
  var xPos, yPos, width, height,index;
  var currentPaint;
  //canvas.drawCircle(Offset(size.width/2, size.height/2), size.width/4, paint);

  //This is where we can draw on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    for(int i=0; i < shapes.length; i++){
      Shape current = shapes[i];
      currentPaint =Paint()
        ..color = current.paint.color
        //..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      if(current is RectShape){
        canvas.drawRect(Rect.fromLTWH(current.xPos, current.yPos, width, height), currentPaint);//current.paint);
      }else if(current is LineShape){
        canvas.drawLine(current.p1, current.p2, currentPaint);
      }else if (current is CircleShape){
        canvas.drawCircle(Offset(current.xPos, current.yPos), current.distance, currentPaint);
      }
      // canvas.clipRect(Rect.fromLTWH(0, 0, size.width/4, size.height/4));
      //canvas.drawRect(Rect.fromLTWH(current.xPos, current.yPos, width, height), paints);//current.paint);
    }
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

//Class to define a point touched at canvas
class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({this.points, this.paint});
}