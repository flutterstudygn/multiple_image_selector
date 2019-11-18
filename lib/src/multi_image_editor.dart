part of image_editor;

class CropOptions {
  final int maxWidth;
  final int maxHeight;
  final CropAspectRatio aspectRatio;
  final List<CropAspectRatioPreset> aspectRatioPresets;
  final CropStyle cropStyle;
  final ImageCompressFormat compressFormat;
  final int compressQuality;
  final AndroidUiSettings androidUiSettings;
  final IOSUiSettings iosUiSettings;

  const CropOptions({
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio,
    this.aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    this.cropStyle = CropStyle.rectangle,
    this.compressFormat = ImageCompressFormat.jpg,
    this.compressQuality = 90,
    this.androidUiSettings,
    this.iosUiSettings,
  });
}

class FilterOptions {
  final List<Filter> _filters;
  List<Filter> get filters => _filters ?? presetFiltersList;

  const FilterOptions({List<Filter> filters}) : _filters = filters;
}

class MultiImageEditor {
  static Future<List<AssetItem>> pickImages(
    BuildContext context, {
    @required int maxImages,
    bool enableCamera = false,
    bool editEnabled = true,
    CropOptions cropOptions = const CropOptions(),
    FilterOptions filterOptions = const FilterOptions(),
    List<Asset> selectedAssets = const [],
    CupertinoOptions cupertinoOptions = const CupertinoOptions(),
    MaterialOptions materialOptions = const MaterialOptions(),
  }) {
    return MultiImagePicker.pickImages(
      maxImages: maxImages,
      enableCamera: enableCamera,
      selectedAssets: selectedAssets,
      cupertinoOptions: cupertinoOptions,
      materialOptions: materialOptions,
    ).then((result) async {
      if (result?.isNotEmpty == true) {
        List<AssetItem> assetItems = await Future.wait(result
            .map((asset) => AssetItem(
                  asset.identifier,
                  asset.name,
                  asset.originalWidth,
                  asset.originalHeight,
                ).init())
            .toList());
        if (editEnabled) {
          assetItems = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageEditorView(
                assetItems,
                cropOptions: cropOptions,
              ),
            ),
          );
          return assetItems;
        } else {
          return assetItems;
        }
      }
      return null;
    });
  }
}
