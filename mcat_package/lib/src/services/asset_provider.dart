abstract class AssetProvider {
  String get logo;
  String get face1;
  String get face2;
  // ... all other assets
}

class PackageAssetProvider implements AssetProvider {
  const PackageAssetProvider(); // Add const constructor

  @override
  String get logo => 'assets/images/carp_logo.png';

  @override
  String get face1 => 'assets/images/face_1.png';

  @override
  String get face2 => 'assets/images/face_2.png';

  // Helper method to load image with package con
}
