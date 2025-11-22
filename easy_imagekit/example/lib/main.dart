import 'dart:ui';

import 'package:easy_imagekit/easy_imagekit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> imageList = [
    'assets/images/1.webp',
    'assets/images/2.png',
    'https://wx3.sinaimg.cn/mw690/008i6kIBly1hp5l4txr49g30f00k0tx4.gif',
    'https://gips1.baidu.com/it/u=112193661,2737838585&fm=3074&app=3074&f=PNG?w=2560&h=1440',
    'https://n.sinaimg.cn/sinacn16/200/w500h500/20180507/6ac0-hacuuvu5054417.gif',
    'https://hbimg.huabanimg.com/85b7d685def3cd17da365dd733d25a1550c973f126b5a-I7H3CW_fw658',
    'assets/images/3.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10),

          child: Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              EasyImage(
                imageList[0],
                style: ImageStyle(
                  width: 150,
                  height: 150,
                  backgroundColor: Colors.white,
                ),
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 0,
                ),
              ),
              EasyImage.circle(
                imageList[1],
                size: 150,
                onTap: () {
                  print('点击了图片');
                },
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 1,
                  customBottomWidgets: [
                    Container(color: Colors.red, height: 100),
                    Container(color: Colors.green, height: 100),
                    Container(color: Colors.blue, height: 100),
                    Container(color: Colors.orange, height: 100),
                    Container(color: Colors.pink, height: 100),
                    Container(color: Colors.orange, height: 100),
                  ],
                ),
              ),

              EasyImage(
                imageList[2],
                style: ImageStyle(
                  width: 150,
                  height: 150,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(180),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 2,
                ),
              ),

              EasyImage(
                imageList[3],
                style: ImageStyle(
                  maxWidth: 150,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(180),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 3,
                ),

                placeholder: Center(child: Text('加载中')),
                errorWidget: Center(child: Text('失败')),
              ),

              EasyImage(
                imageList[4],
                style: ImageStyle(
                  width: 150,
                  height: 150,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  color: Colors.white.withAlpha(180),
                  colorBlendMode: BlendMode.softLight,
                ),
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 4,
                ),

                placeholder: Center(child: Text('加载中')),
                errorWidget: Center(child: Text('失败')),
              ),

              EasyImage.source(
                source: ImageSource.network(imageList[5]),
                style: ImageStyle(
                  maxWidth: 150,
                  borderRadius: 10,
                  backgroundColor: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(180),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                previewConfig: ImagePreviewConfig(
                  images: imageList,
                  initialIndex: 5,
                ),

                placeholder: Center(child: Text('加载中')),
                errorWidget: Center(child: Text('失败')),
              ),

              EasyImage(
                imageList[6],
                style: ImageStyle(
                  width: 150,
                  height: 150,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
