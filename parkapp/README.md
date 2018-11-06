# ParkApp

Project for Embers Porto

## Getting Started

1. Clone Repository.

2. Go to the application directory (`cd <app dir>`).

3. Run `flutter packages get`.

4. Run `flutter run` to open the emulator with the application.

You can use Android Studio instead after the first step.
Just open the project with it and do the same steps with the available tools.

### Build a release APK for Android

Run `flutter build apk` inside the application directory.
The release APK for the ap is created at 
`<app dir>/build/app/outputs/apk/app-release.apk`.

keystore password: 'bitmaker'
key password: 'parkapp'


### Build a release APK for iOS

Check https://flutter.io/ios-release/

#### More Info

https://flutter.io/docs/

### Cheats

## GeoLocator with Map View

Temporary fix until this is fixed:
```
mainPath:
`~/.pub-cache/hosted/pub.dartlang.org/` (for Mac)
`~/flutterInstallationPath/.pub-cache/hosted/pub.dartlang.org/` (for Ubuntu)

In `mainPath/map_view-0.0.14/ios/map_view.podspec`:
add 's.static_framework = true' to the end of the file.

In `mainPath/map_view-0.0.14/ios/Classes/MapViewController.h`:
change '#import <GoogleMaps/GoogleMaps/GMSMapView.h>' for '#import <GoogleMaps/GoogleMaps.h>'
```
Fix for zoomToFit in iOS - add the second for to the following method in `mainPath/map_view-0.0.14/ios/Classes/MapViewController.m`:
```objectivec
- (void)zoomToAnnotations:(int)padding {
    GMSCoordinateBounds *coordinateBounds;
    for (GMSMarker *marker in self.markerIDLookup.allValues) {
        if (!coordinateBounds) {
            coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position coordinate:marker.position];
            continue;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:marker.position];
    }
    for (GMSPolyline *polyline in self.polylineIDLookup.allValues) {
        if (!coordinateBounds) {
            coordinateBounds = [[GMSCoordinateBounds alloc] initWithPath:polyline.path];
            continue;
        }
        coordinateBounds = [coordinateBounds includingPath:polyline.path];
    }
    ...
```
## PointyCastle

Because PointyCastle, is only used in the client, some changes need to be made after using
`package get` command to match the encryption/decryption of the server.
Substitute the following code in the appropriate PointyCastle lib file:

```dart
In 'mainPath/pointycastle-1.0.0-rc4/asymmetric/rsa.dart':

int get outputBlockSize {
    if (_key == null) {
      throw new StateError(
          "Output block size cannot be calculated until init() called");
    }

    var bitSize = _key.modulus.bitLength;
    return (bitSize + 7) ~/ 8;
  }
```