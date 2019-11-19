part of multi_image_selector;

class ImageFilterController extends ValueNotifier<File> {
  ImageFilterController({File value}) : super(value);
  String filename;

  set file(final File file) {
    if (file != null) {
      value = file;
      filename = basename(file.path);
      notifyListeners();
    }
  }

  set filter(Filter filter) {
    if (filterChanged != null) {
      filterChanged(filter);
    }
  }

  ValueChanged<Filter> filterChanged;
}

class ImageFilterSelector extends StatelessWidget {
  final Widget loader;
  final BoxFit fit;
  final ImageFilterController controller;
  final Map<String, List<int>> cachedFilters = {};
  final List<Filter> filters;
  final EditorOptions editorOptions;

  ImageFilterSelector({
    Key key,
    @required this.controller,
    List<Filter> filters,
    this.editorOptions = const EditorOptions(),
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.cover,
  })  : this.filters = filters ?? presetFiltersList,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<ImageFilterController>(
        builder: (_, __, ___) {
          File file = controller.value;
          if (file == null) return Container();
          cachedFilters.clear();
          return FutureBuilder<img.Image>(
            future: _decodeImageFromFile(file,
                resize: editorOptions.thumbnailSize * 2),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: filters.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(editorOptions.marginBetween / 2.0),
                    child: InkWell(
                      onTap: () => controller.filter = filters[index],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildFilterThumbnail(filters[index], snapshot.data,
                              controller.filename),
                          if (editorOptions.showFilterName)
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Container(
                                width: editorOptions.thumbnailSize,
                                child: Center(
                                  child: Text(
                                    filters[index].name,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<img.Image> _decodeImageFromFile(File file, {num resize}) async {
    img.Image image = img.decodeImage(await file.readAsBytes());
    if (resize == null) return image;
    return img.copyResize(image, width: resize.toInt());
  }

  Widget _buildFilterThumbnail(
      Filter filter, img.Image image, String filename) {
    if (image == null) {
      return _buildThumbnailImage(null);
    }
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return _buildThumbnailImage(null);
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return _buildThumbnailImage(cachedFilters[filter?.name ?? "_"]);
          }
          return null; // unreachable
        },
      );
    } else {
      return _buildThumbnailImage(cachedFilters[filter?.name ?? "_"]);
    }
  }

  Widget _buildThumbnailImage(List<int> bytes) {
    switch (editorOptions.filterThumbnailStyle) {
      case FilterThumbnailStyle.CIRCLE:
        return CircleAvatar(
          radius: editorOptions.thumbnailSize / 2,
          backgroundImage: bytes != null ? MemoryImage(bytes) : null,
          child: bytes == null ? loader : Container(),
          backgroundColor: Colors.white,
        );
      case FilterThumbnailStyle.SQUARE:
        return SizedBox(
          width: editorOptions.thumbnailSize,
          height: editorOptions.thumbnailSize,
          child: bytes != null
              ? Image.memory(
                  bytes,
                  width: editorOptions.thumbnailSize,
                  height: editorOptions.thumbnailSize,
                  fit: BoxFit.cover,
                )
              : loader,
        );
    }
    return null; // unreachable
  }
}
