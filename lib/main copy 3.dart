import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(
        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4');
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 3/2,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.lightBlue,
                // child: Center(
                //     child: Text(
                //   "请1201号顾客带餐牌到前台取餐",
                //   style: TextStyle(color: Colors.white, fontSize: 30),
                // )),
                child: Center(
                    child: Chewie(
                  controller: chewieController,
                )),
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
                              top:
                                  BorderSide(color: Colors.white, width: 2.0))),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }
}
