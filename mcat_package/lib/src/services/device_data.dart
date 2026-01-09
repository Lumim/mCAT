import 'dart:io' show Platform;

String DeviceData() {
  // Get the operating system as a string.
  String os = Platform.operatingSystem;
  // Or, use a predicate getter.
  bool isMobile = (os == 'android' || os == 'ios');
  return '''
  {
    "isiPad": false,
    "isMobile": $isMobile,
    "osVersion": "${Platform.operatingSystemVersion}",
    "userAgent": "Unknown",
    "isTouchDevice": $isMobile,
    "possibleDeviceType": "${isMobile ? 'phone' : 'desktop'}"
  }
  ''';
}
