part of image_editor;

class ImageFilterController extends ValueNotifier<File> {
  ImageFilterController({File value}) : super(value);
  String filename;

  set file(File file) {
    value = file;
    filename = file != null ? basename(file.path) : null;
    notifyListeners();
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
  final FilterOptions filterOptions;

  ImageFilterSelector({
    Key key,
    @required this.controller,
    this.filterOptions = const FilterOptions(),
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.cover,
  }) : super(key: key);

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
              future: _decodeImageFromFile(file, resize: 200),
              builder: (context, snapshot) {
                return Container(
                  constraints: BoxConstraints(maxHeight: 140),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterOptions.filters.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildFilterThumbnail(
                                  filterOptions.filters[index],
                                  snapshot.data,
                                  controller.filename),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                filterOptions.filters[index].name,
                              )
                            ],
                          ),
                        ),
                        onTap: () =>
                            controller.filter = filterOptions.filters[index],
                      );
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  Future<img.Image> _decodeImageFromFile(File file, {int resize}) async {
    img.Image image = img.decodeImage(await file.readAsBytes());
    if (resize == null) return image;
    return img.copyResize(image, width: resize);
  }

  _buildFilterThumbnail(Filter filter, img.Image image, String filename) {
    if (image == null) {
      return CircleAvatar(
        radius: 50.0,
        child: Center(
          child: loader,
        ),
        backgroundColor: Colors.white,
      );
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
              return CircleAvatar(
                radius: 50.0,
                child: Center(
                  child: loader,
                ),
                backgroundColor: Colors.white,
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return CircleAvatar(
                radius: 50.0,
                backgroundImage: MemoryImage(
                  snapshot.data,
                ),
                backgroundColor: Colors.white,
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return CircleAvatar(
        radius: 50.0,
        backgroundImage: MemoryImage(
          cachedFilters[filter?.name ?? "_"],
        ),
        backgroundColor: Colors.white,
      );
    }
  }

  Widget buildFilteredImage(AssetItem item) {
    Filter filter = item.filter;
    return FutureBuilder<List<int>>(
      future: _decodeImageFromFile(item.file).then((image) {
        return compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": basename(item.file.path),
        });
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loader;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            cachedFilters[filter?.name ?? "_"] = snapshot.data;
            return Image.memory(
              snapshot.data,
              fit: BoxFit.contain,
            );
        }
        return null; // unreachable
      },
    );
  }
}
