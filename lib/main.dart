import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'components/sywlVideoPlayer.dart';
// import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List orderList = ["100号", "101号", "102号", "103号", "104号"];
  String logo = ""; //logo路径
  String videoPath = ""; //video路径
  String marquee = ""; //滚动字幕
  List imgPathList = []; //轮播图路径

  bool syncUdisk = true;
  bool showAd = false;
  String mm = "";

  @override
  void initState() {
    print("initState...");
    // UsbSerial.usbEventStream.listen((UsbEvent msg) {
    //   print(msg);
    //   if (msg.event == UsbEvent.ACTION_USB_ATTACHED) {
    //     // open a device now...
    //     print(msg.device.toString());
    //     print(msg.event);
    //     setState(() {
    //       mm = msg.device.toString();
    //     });
    //   }
    //   if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
    //     //  close device now...
    //   }
    // });

    _incrementCounter();
  }

  _incrementCounter() async {
    // setState(() {
    //   showAd = !showAd;
    // });
    // print("adfasd");
    BasicMessageChannel channel = new BasicMessageChannel(
        "sywl_basicMessageChannel", StandardMessageCodec());
    String nativeDataDir = await channel.send("dir");
    print("nativeDataDir: ${nativeDataDir}");

    channel.setMessageHandler((message) => Future<String>(() {
          //处理native调用flutter 回调处理函数
          print("message=> ${message}");
          if (message == "begin") {
            setState(() {
              syncUdisk = true;
            });
          } else if (message == "end") {
            setState(() {
              syncUdisk = false;
            });
          }
        }));

    String res_base_path = nativeDataDir + "/res/";
    Directory d = new Directory(res_base_path);
    //
    String _marquee = "";
    String _logo = "";
    List<String> _imgPaths = [];
    String _videoPath = "";

    try {
      if (d.existsSync()) {
        Stream<FileSystemEntity> entityList =
            d.list(recursive: false, followLinks: false);
        await for (FileSystemEntity entity in entityList) {
          if (entity is File) {
            if (entity.path.endsWith("txt")) {
              //marquee滚动字幕
              _marquee = (entity as File).readAsStringSync();
            } else if (entity.path.endsWith("png") ||
                entity.path.endsWith("jpg")) {
              _logo = entity.path;
            }
          } else if (entity is Directory) {
            Directory d = entity as Directory;
            if (d.path.endsWith("imgs")) {
              List<FileSystemEntity> imgsList =
                  await d.list(recursive: false, followLinks: false).toList();
              if (imgsList.length > 0) {
                _imgPaths = imgsList.map((img) => (img as File).path).toList();
              }
            } else if (d.path.endsWith("videos")) {
              List<FileSystemEntity> videoList =
                  await d.list(recursive: false, followLinks: false).toList();
              if (videoList.length > 0) {
                _videoPath =
                    videoList.map((img) => (img as File).path).toList()[0];
              }
            }
          }
        }
      }
    } catch (e) {}

    // String logo = "";//logo路径
    // String videoPath = "";//video路径
    // String marquee = "";//滚动字幕
    // List imgPathList = [];//轮播图路径
    print("asdfa: ${imgPathList}");
    setState(() {
      logo = _logo;
      marquee = _marquee;
      videoPath = _videoPath;
      imgPathList = _imgPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.lightBlue,
                  child: new Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        print("index->: ${index}");
                        if (imgPathList.length > 0) {
                          return new Image.file(new File(imgPathList[index]));
                        } else {
                          return new Image.network(
                            "http://via.placeholder.com/350x150",
                            fit: BoxFit.fill,
                          );
                        }
                      },
                      duration: 1200,
                      itemCount:
                          imgPathList.length > 0 ? imgPathList.length : 1,
                      // pagination: new SwiperPagination(),
                      // control: new SwiperControl(),
                      autoplay: true),
                  // showAd
                  //     ? SywlVideoPlayer(
                  //         width: MediaQuery.of(context).size.width - 220,
                  //         height: MediaQuery.of(context).size.height,
                  //       )
                  //     : Center(
                  //         child: Text(
                  //         "请1201号顾客带餐牌到前台取餐",
                  //         style: TextStyle(color: Colors.white, fontSize: 30),
                  //       ))
                ),
                Positioned(
                  left: 2.0,
                  bottom: 4.0,
                  right: 2.0,
                  child: Container(
                    height: 30,
                    child: MarqueeWidget(
                      text: marquee,
                      textStyle: new TextStyle(fontSize: 20.0),
                      scrollAxis: Axis.horizontal,
                    ),
                  ),
                ),
                Container(
                  child: syncUdisk ? Text("更新数据...") : Text(""),
                )
              ],
            ),
          ),
          Container(
              width: 220,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(width: 2.0, color: Colors.white),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.white, width: 2.0))),
                    height: 70,
                    child: Center(child: new Image.file(new File(logo))),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        //border: Border.all(width: 2.0, color: Colors.white)
                        border: Border(
                      bottom: BorderSide(width: 2.0, color: Colors.white),
                    )),
                    height: 30,
                    child: Center(
                      child: Text(
                        "呼叫已至",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: orderList
                            .map((item) => Text(
                                  item,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ))
                            .toList()),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.white, width: 2.0))),
                    height: 60,
                    child: Center(
                        child: Text(
                      "底部内容",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ],
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
