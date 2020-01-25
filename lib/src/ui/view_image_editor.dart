part of multi_image_selector;

class _ImageEditorNotifier extends ChangeNotifier {
  final List<AssetItem> _assetItems;
  _ImageEditorNotifier(this._assetItems);
  final Map<int, List<int>> _cachedMap = Map();

  int _currentIndex = 0;
  final ImageFilterController _imageFilterController = ImageFilterController();

  @override
  void dispose() {
    _imageFilterController.dispose();
    super.dispose();
  }

  void init() {
    _imageFilterController.filterChanged = (filter) {
      _onFilterEdited(filter);
    };
    Future.delayed(Duration(milliseconds: 250), () {
      _imageFilterController.file = _assetItems[_currentIndex].file;
    });
  }

  set currentIndex(int value) {
    if (_currentIndex != value) {
      _currentIndex = value;
      Future.delayed(Duration(milliseconds: 250), () {
        _imageFilterController.file = _assetItems[_currentIndex].file;
      });
    }
  }

  void onFileEdited(File file) {
    if (file == null) return;
    _cachedMap[_currentIndex] = null;
    _assetItems[_currentIndex].file = file;
    Future.delayed(Duration(milliseconds: 250), () {
      _imageFilterController.file = file;
    });
    notifyListeners();
  }

  void _onFilterEdited(Filter filter) {
    if (_assetItems[_currentIndex].filter != filter) {
      _cachedMap[_currentIndex] = null;
      _assetItems[_currentIndex].filter = filter;
      notifyListeners();
    }
  }

  Widget buildResultImage(
    int idx, {
    BoxFit fit,
    Widget loader = const Center(child: CircularProgressIndicator()),
  }) {
    AssetItem asset = _assetItems[idx];
    if (asset.file == null) {
      return Container();
    }

    if (asset.filter == null) {
      return Image.file(asset.file, fit: fit);
    }

    if (_cachedMap[idx] != null) {
      return Image.memory(_cachedMap[idx], fit: fit);
    }

    return FutureBuilder<List<int>>(
      future: _decodeImageFromFile(asset.file).then((image) {
        return compute(applyFilter, <String, dynamic>{
          "filter": asset.filter,
          "image": image,
          "filename": basename(asset.file.path),
        });
      }).catchError((e) => Future.error(e)),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError) return Image.file(asset.file, fit: fit);
            _cachedMap[idx] = snapshot.data;
            return Image.memory(snapshot.data, fit: fit);
        }
        return null; // unreachable
      },
    );
  }

  Future<img.Image> _decodeImageFromFile(File file, {int resize}) async {
    try {
      img.Image image = img.decodeImage(await file.readAsBytes());
      return img.copyResize(image, width: resize ?? image.width);
    } catch (e) {
      return Future.error(e);
    }
  }
}

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
  _ImageEditorNotifier _notifier;
  @override
  void initState() {
    super.initState();
    _notifier = _ImageEditorNotifier(widget._assetItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget._editorOptions.backgroundColor,
      appBar: AppBar(
        title: widget._editorOptions.title ?? null,
        centerTitle: widget._editorOptions.centerTitle,
        actions: <Widget>[
          IconButton(
            icon: widget._editorOptions.checkIcon,
            onPressed: () {
              Navigator.of(context).pop(widget._assetItems);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Container(
          child: ChangeNotifierProvider<_ImageEditorNotifier>.value(
            value: _notifier..init(),
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
                          _notifier.currentIndex = idx;
                        },
                        items: List.generate(
                          widget._assetItems?.length ?? 0,
                          (idx) {
                            AssetItem imageItem = widget._assetItems[idx];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Consumer<_ImageEditorNotifier>(
                                builder: (_, notifier, __) {
                                  return InkWell(
                                    onTap: () async {
                                      if (notifier._currentIndex == idx) {
                                        File result = await _cropImages(
                                            context, imageItem.file.path);
                                        notifier.onFileEdited(result);
                                      }
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Material(
                                            elevation: 4.0,
                                            child: notifier.buildResultImage(
                                              idx,
                                              fit: widget._cropOptions.fit,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomRight,
                                          child: IgnorePointer(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
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
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: widget._editorOptions.thumbnailSize +
                        widget._editorOptions.marginBetween * 2 +
                        40.0,
                  ),
                  child: ImageFilterSelector(
                    controller: _notifier._imageFilterController,
                    filters: widget.filters,
                    editorOptions: widget._editorOptions,
                  ),
                ),
              ],
            ),
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
