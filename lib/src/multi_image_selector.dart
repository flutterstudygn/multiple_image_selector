part of multi_image_selector;

class CropOptions {
  final int maxWidth;
  final int maxHeight;
  final CropAspectRatio _aspectRatio;
  final List<CropAspectRatioPreset> aspectRatioPresets;
  final ImageCompressFormat compressFormat;
  final int compressQuality;
  final AndroidUiSettings androidUiSettings;
  final IOSUiSettings iosUiSettings;

  const CropOptions({
    this.maxWidth,
    this.maxHeight,
    CropAspectRatio aspectRatio,
    this.aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    this.compressFormat = ImageCompressFormat.jpg,
    this.compressQuality = 90,
    this.androidUiSettings,
    this.iosUiSettings,
  }) : _aspectRatio = aspectRatio;

  CropAspectRatio get aspectRatio {
    if (_aspectRatio != null) {
      return _aspectRatio;
    }
    if (aspectRatioPresets?.length == 1) {
      switch (aspectRatioPresets[0]) {
        case CropAspectRatioPreset.original:
          return null;
        case CropAspectRatioPreset.square:
          return CropAspectRatio(ratioX: 1, ratioY: 1);
        case CropAspectRatioPreset.ratio3x2:
          return CropAspectRatio(ratioX: 3, ratioY: 2);
        case CropAspectRatioPreset.ratio5x3:
          return CropAspectRatio(ratioX: 5, ratioY: 3);
        case CropAspectRatioPreset.ratio4x3:
          return CropAspectRatio(ratioX: 4, ratioY: 3);
        case CropAspectRatioPreset.ratio5x4:
          return CropAspectRatio(ratioX: 5, ratioY: 4);
        case CropAspectRatioPreset.ratio7x5:
          return CropAspectRatio(ratioX: 7, ratioY: 5);
        case CropAspectRatioPreset.ratio16x9:
          return CropAspectRatio(ratioX: 16, ratioY: 9);
      }
    }
    return null;
  }

  BoxFit get fit {
    if (aspectRatioPresets?.length == 1) {
      switch (aspectRatioPresets[0]) {
        case CropAspectRatioPreset.original:
        case CropAspectRatioPreset.ratio3x2:
        case CropAspectRatioPreset.ratio5x3:
        case CropAspectRatioPreset.ratio4x3:
        case CropAspectRatioPreset.ratio5x4:
        case CropAspectRatioPreset.ratio7x5:
        case CropAspectRatioPreset.ratio16x9:
          return null;
        case CropAspectRatioPreset.square:
          return BoxFit.cover;
      }
    }
    return null;
  }
}

enum FilterThumbnailStyle { CIRCLE, SQUARE }

class EditorOptions {
  final Color backgroundColor;
  final Color imageBackgroundColor;

  final Widget title;
  final bool centerTitle;
  final Icon checkIcon;

  final double thumbnailSize;
  final double marginBetween;
  final bool showFilterName;
  final FilterThumbnailStyle filterThumbnailStyle;

  const EditorOptions({
    this.backgroundColor = const Color(0xffffffff),
    this.imageBackgroundColor = const Color(0x33cccccc),
    this.title,
    this.centerTitle = true,
    this.checkIcon = const Icon(Icons.check),
    this.thumbnailSize = 100.0,
    this.filterThumbnailStyle = FilterThumbnailStyle.SQUARE,
    this.marginBetween = 5.0,
    this.showFilterName = true,
  });
}

class MultiImageSelector {
  static Future<List<AssetItem>> pickImages(
    BuildContext context, {
    @required int maxImages,
    bool enableCamera = false,
    bool editEnabled = true,
    CropOptions cropOptions = const CropOptions(),
    List<Filter> filters,
    EditorOptions editorOptions = const EditorOptions(),
    List<AssetItem> selectedAssets = const [],
    CupertinoOptions cupertinoOptions = const CupertinoOptions(),
    MaterialOptions materialOptions = const MaterialOptions(),
  }) async {
    List<AssetItem> assetItems;
    if (selectedAssets.isEmpty || !editEnabled) {
      try {
        List<Asset> result = await MultiImagePicker.pickImages(
          maxImages: maxImages,
          enableCamera: enableCamera,
          selectedAssets: selectedAssets,
          cupertinoOptions: cupertinoOptions,
          materialOptions: materialOptions,
        );
        assetItems = await Future.wait(result
            .map((asset) => AssetItem(
                  asset.identifier,
                  asset.name,
                  asset.originalWidth,
                  asset.originalHeight,
                ).init())
            .toList());
      } catch (e) {
        return null;
      }
    } else {
      assetItems = selectedAssets;
    }

    if (assetItems?.isNotEmpty == true) {
      if (editEnabled) {
        assetItems = await editImages(
          context,
          assetItems,
          filters: filters,
          cropOptions: cropOptions,
          editorOptions: editorOptions,
        );
        return assetItems;
      } else {
        return assetItems;
      }
    }
    return null;
  }

  static Future<List<AssetItem>> editImages(
    BuildContext context,
    List<AssetItem> selectedAssets, {
    CropOptions cropOptions = const CropOptions(),
    List<Filter> filters,
    EditorOptions editorOptions = const EditorOptions(),
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageEditorView(
          selectedAssets,
          filters: filters,
          cropOptions: cropOptions,
          editorOptions: editorOptions,
        ),
      ),
    );
  }
}
