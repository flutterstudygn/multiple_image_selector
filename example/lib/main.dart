import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_cropper/image_cropper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AssetItem> _assetList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          itemCount: _assetList?.length ?? 0,
          itemBuilder: (context, idx) {
            return AspectRatio(
              aspectRatio: 1.0,
              child: _assetList[idx].buildResultImage(),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          _assetList = await MultiImageEditor.pickImages(
            context,
            editEnabled: true,
            maxImages: 3,
            enableCamera: true,
            selectedAssets: _assetList ?? [],
            cropOptions: CropOptions(
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
              androidUiSettings: AndroidUiSettings(
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: const Color(0xffffffff),
                toolbarTitle: '',
              ),
            ),
            editorOptions: EditorOptions(
              filterThumbnailStyle: FilterThumbnailStyle.SQUARE,
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}
