import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tf_pdf/tf_pdf.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = '';

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
                if (Platform.isAndroid) {
                  var b = await checkAndRequest(PermissionGroup.storage);
                  if (!b) {
                    setState(() => text = '（安卓）请求文件存储权限');
                    return;
                  }
                }

                var pdfPath = await TfPdf.createPDFByImage(
                  imgPaths,
                  width: 200,
                  height: 250,
                );
                setState(() => text = 'pdfPath = ${pdfPath}');
                print('pdfPath = ${pdfPath}');
              },
            ),
          ],
        ),
        body: Center(
          child: Text(text),
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

  Future<bool> checkAndRequest(PermissionGroup permissionGroup) async {
    var permissionHandler = PermissionHandler();
    var permissionStatus =
        await permissionHandler.checkPermissionStatus(permissionGroup);
    if (permissionStatus == PermissionStatus.granted) return true;

    var requestResults =
        await permissionHandler.requestPermissions([permissionGroup]);

    if (requestResults[permissionGroup] == PermissionStatus.granted)
      return true;
    return false;
  }
}
