part of image_editor;

class ImageEditorView extends StatefulWidget {
  final CropOptions _cropOptions;
  final FilterOptions _filterOptions;
  final List<AssetItem> _assetItems;
  ImageEditorView(
    this._assetItems, {
    CropOptions cropOptions,
    FilterOptions filterOptions,
  })  : _cropOptions = cropOptions ?? const CropOptions(),
        _filterOptions = filterOptions ?? const FilterOptions();

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
                  _imageFilterController.file = widget._assetItems[idx].file;
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
                        child: Stack(
                          children: <Widget>[
                            Center(child: imageItem.buildResultImage())
                          ],
                        ),
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
      ),
    );
  }

  Future<File> _cropImages(BuildContext context, String filePath) async {
    return ImageCropper.cropImage(
      sourcePath: filePath,
      aspectRatio: widget._cropOptions
          .aspectRatio, //CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      aspectRatioPresets: widget
          ._cropOptions.aspectRatioPresets, //[CropAspectRatioPreset.square],
    );
  }
}
