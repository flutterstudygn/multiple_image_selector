part of image_editor;

class ImageEditorView extends StatefulWidget {
  final List<AssetItem> _assetItems;
  final CropOptions _cropOptions;
  final List<Filter> filters;
  final EditorOptions _editorOptions;

  ImageEditorView(
    this._assetItems, {
    CropOptions cropOptions,
    this.filters,
    EditorOptions editorOptions,
  })  : _cropOptions = cropOptions ?? const CropOptions(),
        _editorOptions = editorOptions ?? const EditorOptions();

  @override
  _ImageEditorViewState createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  final ImageFilterController _imageFilterController = ImageFilterController();

  int _currentCarouselIndex = 0;

  final GlobalKey _keyFilterSelector =
      GlobalKey(debugLabel: '_keyFilterSelector');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageFilterController.file =
          widget._assetItems[_currentCarouselIndex].file;
      _imageFilterController.filterChanged = (filter) {
        widget._assetItems[_currentCarouselIndex].filter = filter;
        setState(() {});
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
    return Scaffold(
      backgroundColor: widget._editorOptions.backgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(widget._assetItems);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CarouselSlider(
                      aspectRatio: 1 / 0.78,
                      viewportFraction: 0.8,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      onPageChanged: (idx) {
                        _currentCarouselIndex = idx;
                        _imageFilterController.file =
                            widget._assetItems[idx].file;
                      },
                      items: List.generate(
                        widget._assetItems?.length ?? 0,
                        (idx) {
                          AssetItem imageItem = widget._assetItems[idx];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: () async {
                                if (_currentCarouselIndex == idx) {
                                  File result = await _cropImages(
                                      context, imageItem.file.path);
                                  _imageFilterController.file = result;
                                  widget._assetItems[idx].file = result;
                                  setState(() {});
                                }
                              },
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Material(
                                      elevation: 4.0,
                                      child: imageItem.buildResultImage(
                                        fit: widget._cropOptions.fit,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: IgnorePointer(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          radius: 15,
                                          child: Icon(
                                            Icons.crop,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ImageFilterSelector(
                  controller: _imageFilterController,
                  filters: widget.filters,
                  editorOptions: widget._editorOptions,
                  key: _keyFilterSelector,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File> _cropImages(BuildContext context, String filePath) async {
    return ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: widget._cropOptions.maxWidth,
      maxHeight: widget._cropOptions.maxHeight,
      aspectRatio: widget._cropOptions.aspectRatio,
      aspectRatioPresets: widget._cropOptions.aspectRatioPresets,
      compressFormat: widget._cropOptions.compressFormat,
      compressQuality: widget._cropOptions.compressQuality,
      androidUiSettings: widget._cropOptions.androidUiSettings,
      iosUiSettings: widget._cropOptions.iosUiSettings,
    );
  }
}
