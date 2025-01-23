import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';

import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vap_test/vap/flutter_vap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;

  @override
  void initState() {
    super.initState();
     initDownloadPath();
  }

  Future<void> initDownloadPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String rootPath = appDocDir.path;
    downloadPathList = ["$rootPath/vap_demo1.mp4", "$rootPath/vap_demo2.mp4"];
    print("downloadPathList:$downloadPathList");
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 140, 41, 43),
              image: DecorationImage(image: AssetImage("assets/bg.jpeg")),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text(
                          "download video source${isDownload ? "(✅)" : ""}"),
                      onPressed: _download,
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("File1 play"),
                      onPressed: () => _playFile(downloadPathList[0]),
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("File2 play"),
                      onPressed: () => _playFile(downloadPathList[1]),
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("asset play"),
                      onPressed: () => _playAsset("static/demo.mp4"),
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("stop play"),
                      onPressed: () => VapController.stop(),
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("queue play"),
                      onPressed: _queuePlay,
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("cancel queue play"),
                      onPressed: _cancelQueuePlay,
                    ),
                  ],
                ),
                IgnorePointer(
                  // VapView可以通过外层包Container(),设置宽高来限制弹出视频的宽高
                  // VapView can set the width and height through the outer package Container() to limit the width and height of the pop-up video
                  child: VapView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _download() async {
    await Dio().download(
        "https://res.cloudinary.com/dkmchpua1/video/upload/v1737623468/zta2wxsuokcskw0bhar7.mp4",
        downloadPathList[0]);
    await Dio().download(
        "https://res.cloudinary.com/dkmchpua1/video/upload/v1737624783/vcg9co6yyfqsadgety1n.mp4",
        downloadPathList[1]);
    setState(() {
      isDownload = true;
    });
  }

  Future<Map<dynamic, dynamic>?> _playFile(String path) async {
    if (path == null) {
      return null;
    }
    var res = await VapController.playPath(path);
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
    if (asset == null) {
      return null;
    }
    var res = await VapController.playAsset(asset);
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  _queuePlay() async {
    // 模拟多个地方同时调用播放,使得队列执行播放。
    // Simultaneously call playback in multiple places, making the queue perform playback.
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[0]));
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[1]));
  }

  _cancelQueuePlay() {
    QueueUtil.get("vapQueue")?.cancelTask();
  }
}
