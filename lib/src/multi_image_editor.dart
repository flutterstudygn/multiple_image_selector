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

enum FilterThumbnailStyle { CIRCLE, SQUARE }

class EditorOptions {
  final Color backgroundColor;
  final Color imageBackgroundColor;

  final double thumbnailSize;
  final double marginBetween;
  final bool showFilterName;
  final FilterThumbnailStyle filterThumbnailStyle;

  const EditorOptions({
    this.backgroundColor = const Color(0xffffffff),
    this.imageBackgroundColor = const Color(0xffcccccc),
    this.thumbnailSize = 100.0,
    this.filterThumbnailStyle = FilterThumbnailStyle.CIRCLE,
    this.marginBetween = 5.0,
    this.showFilterName = true,
  });
}

class MultiImageEditor {
  static Future<List<AssetItem>> pickImages(
    BuildContext context, {
    @required int maxImages,
    bool enableCamera = false,
    bool editEnabled = true,
    CropOptions cropOptions = const CropOptions(),
    List<Filter> filters,
    EditorOptions editorOptions = const EditorOptions(),
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
                filters: filters,
                cropOptions: cropOptions,
                editorOptions: editorOptions,
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
