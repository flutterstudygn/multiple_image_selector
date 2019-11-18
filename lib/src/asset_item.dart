part of image_editor;

class AssetItem extends Asset {
  AssetItem(
      String identifier, String name, int originalWidth, int originalHeight)
      : super(identifier, name, originalWidth, originalHeight);

  File file;
  Future<AssetItem> init() async {
    file = File(await filePath);
    return this;
  }

  Filter filter;

  Future<img.Image> _decodeImageFromFile(File file, {int resize}) async {
    img.Image image = img.decodeImage(await file.readAsBytes());
    if (resize == null) return image;
    return img.copyResize(image, width: resize);
  }

  Widget buildResultImage({
    BoxFit fit,
    Widget loader = const Center(child: CircularProgressIndicator()),
  }) {
    if (this.file == null) {
      return Container();
    }
    if (this.filter == null) {
      return Image.file(this.file, fit: fit);
    }
    return FutureBuilder<List<int>>(
      future: _decodeImageFromFile(this.file).then((image) {
        return compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": basename(this.file.path),
        });
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            return Image.memory(snapshot.data, fit: fit);
        }
        return null; // unreachable
      },
    );
  }

  Future<File> save(String path) {
    return file.copy(path);
  }

  uploadFirestore() {}

  uploadS3() {}
}
