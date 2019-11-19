# image_editor

A new Flutter package for multiple image picker, cropper and filtering.

## Key features
* Pick multiple images.
* Take a picture in the grid view.
* Restrict the maximum count of images the user can pick.
* Adjust cropping for each images.
* Adjust filter for each images.

## Based on
* [multi_image_picker](https://pub.dev/packages/multi_image_picker)
* [image_cropper](https://pub.dev/packages/image_cropper)
* [photofilters](https://pub.dev/packages/photofilters)

## Installing
### pubspec.yaml

### Initial setup
**iOS**
* Add permission(multi_image_picker) into `Info.plist`
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Example usage description</string>
<key>NSCameraUsageDescription</key>
<string>Example usage description</string>
```

**Android**
* Add permission(multi_image_picker) into `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```
* Add UcropActivity(image_cropper) into `AndroidManifest.xml`
```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```
