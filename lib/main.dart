import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'components/sywlVideoPlayer.dart';
import 'package:usb_serial/usb_serial.dart';

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
  bool showAd = false;
  String mm = "";

  @override
  void initState() {
    print("initState...");
    UsbSerial.usbEventStream.listen((UsbEvent msg) {
      print(msg);
      if (msg.event == UsbEvent.ACTION_USB_ATTACHED) {
        // open a device now...
        print(msg.device.toString());
        print(msg.event);
        setState(() {
          mm = msg.device.toString();
        });
      }
      if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
        //  close device now...
      }
    });
  }

  _incrementCounter() async {
    String path = (await getExternalStorageDirectory()).path;
    print("path: ${path}");
    String sTempDir = (await getTemporaryDirectory()).path;
    print("sTempDir: ${sTempDir}");
    String sDocumentDir = (await getApplicationDocumentsDirectory()).path;
    print("sDocumentDir: ${sDocumentDir}");
    setState(() {
      showAd = !showAd;
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
                        return new Image.network(
                          "http://via.placeholder.com/350x150",
                          fit: BoxFit.fill,
                        );
                      },
                      duration: 1200,
                      itemCount: 3,
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
                      text: "ListView即滚动列表控件，能将子控件组成可滚动的列表。当你需要排列的子控件超出容器大小",
                      textStyle: new TextStyle(fontSize: 20.0),
                      scrollAxis: Axis.horizontal,
                    ),
                  ),
                ),
                Container(
                  child: Text(mm),
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
                    child: Center(
                        child: Text(
                      "LOGO",
                      style: TextStyle(color: Colors.white),
                    )),
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
