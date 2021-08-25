import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:draftching/shape.dart';
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

class _CanvasPaintingState extends State<CanvasPainting> {
    GlobalKey globalKey = GlobalKey();
    List<TouchPoints> points = List();
    double opacity = 1.0;
    Color selectedColor = Colors.black;
    List<Shape> shape =[];
    bool freeHandOn = false;
    bool rotateOn = false;
    var _x,_y,_len;
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
                    //strokeWidth = 3.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 24,
                  ),
                  onPressed: () {
                    //strokeWidth = 10.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 40,
                  ),
                  onPressed: () {
                    //strokeWidth = 30.0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Icon(
                    Icons.brush,
                    size: 60,
                  ),
                  onPressed: () {
                    //strokeWidth = 50.0;
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
          heroTag: "line_shape",
          child: Icon(Icons.arrow_right_alt_outlined),
          tooltip: 'Line',
          onPressed: () {
            //min: 0, max: 50
            setState(() {
              // _pickStroke();
              shapeSetUp();
              shape.add(new LineShape(this.selectedColor));
              shape.last.onFocus = true;
            });
          },
        ),
        FloatingActionButton(
          heroTag: "rect_shape",
          child: Icon(Icons.web_asset_outlined),
          tooltip: 'Rectangle',
          onPressed: () {
            //min:0, max:1
            setState(() {
              // _opacity();
              shapeSetUp();
              shape.add(new RectShape(this.selectedColor));
              shape.last.onFocus = true;
            });
          },
        ),
        FloatingActionButton(
            heroTag: "circle_shape",
            child: Icon(Icons.adjust_rounded),
            tooltip: "Circle",
            onPressed: () {
              setState(() {
                shapeSetUp();
                shape.add(new CircleShape(this.selectedColor));
                shape.last.onFocus = true;
              });
            }),
        FloatingActionButton(
            heroTag: "freeHand",
            child: Icon(Icons.brush),
            tooltip: "FreeHand",
            onPressed: () {
              setState(() {
                shapeSetUp();
                shape.add(new FreeHandShape(this.selectedColor));
                freeHandOn = true;
                shape.last.onFocus = true;
              });
            }),
        FloatingActionButton(
            heroTag: "rotate",
            child: Icon(Icons.architecture),
            tooltip: "Rotate",
            onPressed: () {
              setState(() {
                //freeHandOn = false;
                if(shape.last.rotate){
                  shape.last.rotate = false;
                }else{
                  shape.last.rotate = true;
                }
                //points.clear();
              });
            }),
        FloatingActionButton(
          heroTag: "alter_shape",
          child: Icon(Icons.all_out_rounded),
          tooltip: 'alter',
          onPressed: () {
            //min: 0, max: 50
            setState(() {
              // _pickStroke();
              freeHandOn = false;
              shape.last.rotate = false;
              if(shape.last.alter){
                shape.last.alter = false;
              }else{
                shape.last.alter = true;
              }

            });
          },
        ),
        FloatingActionButton(
            heroTag: "erase",
            child: Icon(Icons.clear),
            tooltip: "Erase",
            onPressed: () {
              setState(() {
                freeHandOn = false;
                shape.removeLast();
                if(shape.isNotEmpty) {
                  shape.last.onFocus = true;
                }
                //points.clear();
              });
            }),
        // FloatingActionButton(
        //   backgroundColor: Colors.white,
        //   heroTag: "color_blue",
        //   child: colorMenuItem(Colors.blue),
        //   tooltip: 'Color',
        //   onPressed: () {
        //     setState(() {
        //       selectedColor = Colors.blue;
        //     });
        //   },
        // ),
      ];
    }

    shapeSetUp(){
      freeHandOn = false;
      if(shape.isNotEmpty){
        shape.last.setPaint(Colors.black);
        shape.last.rotate = false;
        shape.last.alter = false;
        shape.last.onFocus = false;
      }
    }

    actionWhenFreeHandisOn(details){
      RenderBox renderBox = context.findRenderObject();
      shape.last.pointsList.add(TouchPoints(
          points: renderBox.globalToLocal(
              details.globalPosition),
          paint: shape.last.paint));

    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                if (shape.last.rotate) {
                  shape.last.scrollPos -= details.globalPosition.dx - _x;
                  _x = details.globalPosition.dx;
                } else if (shape.last.alter) {
                  shape.last.setWidth(-(details.globalPosition.dy - _y));
                  shape.last.setHeight(-(details.globalPosition.dx - _x));
                  _y = details.globalPosition.dy;
                  _x = details.globalPosition.dx;
                }else {
                  if (freeHandOn) {
                    actionWhenFreeHandisOn(details);
                  } else {
                    shape.last.setPosition(details);
                  }
                }
              });
            },
            onPanStart: (details) {
              setState(() {
                if (freeHandOn) {
                  actionWhenFreeHandisOn(details);
                }else if (shape.last.rotate || shape.last.alter) {
                  _x = details.globalPosition.dx;
                  _y = details.globalPosition.dy;
                }
              });

              //_dragging = _insideRect(details.globalPosition.dx,details.globalPosition.dy,);
            },
            onPanEnd: (details) {
              setState(() {
                _dragging = false;
                if (freeHandOn) {
                  points.add(null);
                }
              });
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
                        shapes: this.shape,
                        degrees: this._len
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
  MyPainter({
        this.width,
        this.height,
        this.index,
        this.selectedColor,
        this.shapes,
        this.degrees
        //this.pointsList,
        //this.offsetPoints
      });
  Paint painting = new Paint();

  Color selectedColor;
  //Keep track of the points tapped on the screen
  List<Shape> shapes = [];
  var xPos, yPos, width, height,index;
  var currentPaint,degrees,radians;
  //canvas.drawCircle(Offset(size.width/2, size.height/2), size.width/4, paint);

  //This is where we can draw on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    for(int i=0; i < shapes.length; i++){
      Shape thisShape = shapes[i];
      currentPaint =getShapeColor(thisShape);
      canvas.save();
      degrees = thisShape.scrollPos;
      radians = degrees * math.pi / 180;
      if(thisShape is RectShape || thisShape is LineShape){
        rotate(canvas,thisShape.getXMiddlePoint(), thisShape.getYMiddlePoint(),radians);
      }


      if(thisShape is RectShape){
        canvas.drawRect(Rect.fromLTWH(thisShape.xPos, thisShape.yPos, thisShape.getHeight(), thisShape.getWidth()), currentPaint);//thisShape.paint);
      }else if(thisShape is LineShape){
        canvas.drawLine(thisShape.getP1(), thisShape.getP2(), currentPaint);
      }else if (thisShape is CircleShape){
        canvas.drawCircle(Offset(thisShape.xPos, thisShape.yPos), thisShape.getWidth(), currentPaint);
      }else if(thisShape is FreeHandShape){
        List<TouchPoints> pointsList = thisShape.pointsList;
        List<Offset> offsetPoints = thisShape.offsetPoints;
        for (int i = 0; i < pointsList.length - 1; i++) {
          if (pointsList[i] != null && pointsList[i + 1] != null) {
            //Drawing line when two consecutive points are available
            canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,thisShape.getCurrentPaint());
          } else if (pointsList[i] != null && pointsList[i + 1] == null) {
            offsetPoints.clear();
            offsetPoints.add(pointsList[i].points);
            offsetPoints.add(Offset(pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
            //Draw points when two points are not next to each other
            canvas.drawPoints(ui.PointMode.points, offsetPoints, thisShape.getCurrentPaint());
          }
        }
      }
      canvas.restore();
      // canvas.clipRect(Rect.fromLTWH(0, 0, size.width/4, size.height/4));
      //canvas.drawRect(Rect.fromLTWH(thisShape.xPos, thisShape.yPos, width, height), paints);//thisShape.paint);
    }
  }
  @override
  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);
  }

  Paint getShapeColor(Shape thisShape){
    if(thisShape.onFocus){
      thisShape.setPaint(Colors.red);
    }
    return Paint()
      ..color = thisShape.paint.color
    //..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

