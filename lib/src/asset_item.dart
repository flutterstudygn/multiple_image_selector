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
}
