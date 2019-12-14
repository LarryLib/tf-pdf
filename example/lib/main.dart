import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tf_pdf/tf_pdf.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            FlatButton(
              child: Text('createPDF'),
              onPressed: () async {
                var imgPaths = List<String>();
                for (var i = 1; i < 9; i++) {
                  var file = await saveByName('images/tagskin${i}.png');
                  imgPaths.add(file.path);
                }
                var gifPath = await TfPdf.createPDFByImage(
                  imgPaths,
                  width: 200,
                  height: 250,
                );
                print('gifPath = ${gifPath}');
              },
            ),
          ],
        ),
        body: Center(
          child: Text(''),
        ),
      ),
    );
  }

  Future<File> saveByName(String imgName) async {
    var file = await getFile(imgName);
    await file.createSync(recursive: true);
    final byteData = await rootBundle.load(imgName);
    final bytes = byteData.buffer.asUint8List();
    await file.writeAsBytesSync(bytes);

    print('filePath = ${file.path}');
    return file;
  }

  Future<File> getFile(String name) async {
    var documentsDir = await getApplicationDocumentsDirectory();
    return File("${documentsDir.path}/$name");
  }
}
