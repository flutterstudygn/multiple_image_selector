part of image_editor;

class ImageEditorView extends StatefulWidget {
  final List<AssetItem> _assetItems;
  ImageEditorView(this._assetItems);

  @override
  _ImageEditorViewState createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  final ImageFilterController _imageFilterController = ImageFilterController();

  int _currentCarouselIndex = 0;

  GlobalKey _keyFilterSelector = GlobalKey(debugLabel: '_keyFilterSelector');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageFilterController.file =
          widget._assetItems[_currentCarouselIndex].file;
      _imageFilterController.filterChanged = (filter) {
        widget._assetItems[_currentCarouselIndex].filter = filter;
      };
    });
  }

  @override
  void dispose() {
    _imageFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Container(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.0,
            child: CarouselSlider(
              aspectRatio: 1 / 0.78,
              viewportFraction: 0.8,
              autoPlay: false,
              enableInfiniteScroll: false,
              onPageChanged: (idx) {
                _currentCarouselIndex = idx;
                Future.delayed(Duration.zero, () {
                  _imageFilterController.file = widget._assetItems[idx].file;
                  setState(() {});
                });
              },
              items: List.generate(
                widget._assetItems?.length ?? 0,
                (idx) {
                  AssetItem imageItem = widget._assetItems[idx];
                  return InkWell(
                    onTap: () async {
                      if (_currentCarouselIndex == idx) {
                        File result =
                            await _cropImages(context, imageItem.file.path);
                        _imageFilterController.file = result;
                        widget._assetItems[idx].file = result;
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: imageItem.filter == null
                          ? Image.file(imageItem.file, fit: BoxFit.cover)
                          : (_keyFilterSelector.currentWidget
                                  as ImageFilterSelector)
                              .buildFilteredImage(imageItem),
                    ),
                  );
                },
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Center(
                child: ImageFilterSelector(
                  controller: _imageFilterController,
                  key: _keyFilterSelector,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Future<File> _cropImages(BuildContext context, String filePath) async {
    return ImageCropper.cropImage(
      sourcePath: filePath,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      cropStyle: CropStyle.rectangle,
      androidUiSettings: AndroidUiSettings(
        statusBarColor: Colors.white,
        showCropGrid: true,
      ),
      iosUiSettings: IOSUiSettings(),
    );
  }
}
