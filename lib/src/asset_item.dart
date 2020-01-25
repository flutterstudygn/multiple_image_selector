part of multi_image_selector;

class AssetItem extends Asset {
  AssetItem(
      String identifier, String name, int originalWidth, int originalHeight)
      : super(identifier, name, originalWidth, originalHeight);

  File file;
  Future<AssetItem> init() async {
//    file = File();
//    file.writeAsBytesSync((await getByteData()));
    return this;
  }

  String get _ext {
    List<String> path = super.name?.split('.');
    if ((path?.length ?? 0) > 1) {
      return path[path.length - 1];
    }
    return null;
  }

  Filter filter;

  Future<img.Image> _decodeImageFromFile(File file, {int resize}) async {
    try {
      img.Image image = img.decodeImage(await file.readAsBytes());
      if (image == null) return Future.error('');
      if (resize == null) return image;
      return img.copyResize(image, width: resize);
    } catch (e) {
      return Future.error(e);
    }
  }

  Widget buildResultImage({
    BoxFit fit,
    Widget loader = const Center(child: CircularProgressIndicator()),
  }) {
    if (this.file == null) {
      return Container();
    }
    if (this.filter == null || filter is NoFilter) {
      return Image.file(this.file, fit: fit);
    }
    return FutureBuilder<List<int>>(
      future: _readFilteredBytes(),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError) return Image.file(file, fit: fit);
            return Image.memory(snapshot.data, fit: fit);
        }
        return null; // unreachable
      },
    );
  }

  Future<List<int>> _readFilteredBytes() {
    return _decodeImageFromFile(this.file).then((image) {
      return compute(applyFilter, <String, dynamic>{
        "filter": this.filter,
        "image": image,
        "filename": super.name,
      });
    }).catchError((e) => Future.error(e));
  }

  Future<File> save(String path) {
    return file.copy(path);
  }

  Future<StorageTaskSnapshot> uploadFirestore(
    String path, {
    String name,
    bool addExt = false,
  }) async {
    StorageReference ref = FirebaseStorage().ref();
    path.split('/').forEach((p) {
      ref = ref.child(p);
    });

    String childName = super.name;
    if (name?.isNotEmpty == true) {
      childName = name;
      if (addExt) {
        String ext = _ext;
        if (ext != null) {
          childName += '.$ext';
        }
      }
    }
    ref = ref.child(childName);

    if (filter == null || filter is NoFilter) {
      return ref.putFile(file).onComplete;
    } else {
      return ref.putData(await _readFilteredBytes()).onComplete;
    }
  }

  uploadS3() {}
}
