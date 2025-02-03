// ignore_for_file: library_private_types_in_public_api

import 'dart:collection';
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
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;
  bool isPlaying = false;
  Queue<String> videoQueue = Queue<String>();
  late VapController _vapController;
  @override
  void initState() {
    super.initState();
    _vapController = VapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vapController.init();
      _setupVideoListener();
    });

    initDownloadPath();
  }

  Future<void> initDownloadPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String rootPath = appDocDir.path;
    downloadPathList = ["$rootPath/vap_demo1.mp4", "$rootPath/vap_demo2.mp4"];
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage("assets/dev_bg.png"), fit: BoxFit.contain),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        CupertinoButton(
                          color: Color(0xff6c63ff),
                          onPressed: _download,
                          child: Text(
                              "download video source${isDownload ? "(✅)" : ""}"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CupertinoButton(
                          color: Color(0xff6c63ff),
                          child: Text("File1 play"),
                          onPressed: () => _playFile(downloadPathList[0]),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CupertinoButton(
                          color: Color(0xff6c63ff),
                          child: Text("asset play"),
                          onPressed: () => _playAsset("assets/demo.mp4"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CupertinoButton(
                          color: Color(0xff6c63ff),
                          child: Text("asset play Two"),
                          onPressed: () => _playAsset("assets/demo.mp4"),
                        ),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: VapView(controller: _vapController),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _download() async {
    await Dio().download(
        "https://hillive.com/uploads/gift/weddingcarok.mp4",
        downloadPathList[0]);

    setState(() {
      isDownload = true;
    });
  }

  Future<Map<dynamic, dynamic>?> _playFile(String path) async {
    var res = await _vapController.playPath(path);
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  void _setupVideoListener() {
    _vapController.onVideoComplete = () {
      _playNextVideo();
    };
  }

  void _playNextVideo() {
    if (videoQueue.isNotEmpty) {
      String nextVideo = videoQueue.removeFirst();
      _vapController.playAsset(nextVideo);
    } else {
      isPlaying = false;
    }
  }

  Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
    if (isPlaying) {
      videoQueue.add(asset);
      return null;
    }

    isPlaying = true;
    var res = await _vapController.playAsset(asset);
    if (res!["status"] == "failure") {
      isPlaying = false;
      showToast(res["errorMsg"]);
    }
    return res;
  }

  @override
  void dispose() {
    videoQueue.clear();
    isPlaying = false;
    _vapController.dispose();
    super.dispose();
  }
}
