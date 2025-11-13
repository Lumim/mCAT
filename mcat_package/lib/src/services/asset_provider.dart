// lib/services/asset_provider.dart

abstract class AssetProvider {
  String get logo;
  String get face1;
  String get face2;
  // add other assets here...
}

class PackageAssetProvider implements AssetProvider {
  const PackageAssetProvider();

  @override
  String get logo => 'assets/images/carp_logo.png';

  @override
  String get face1 => 'assets/images/face_1.png';

  @override
  String get face2 => 'assets/images/face_2.png';

  // ...and the rest of your assets
}

// ✅ Simple global locator for assets
class ServiceLocator {
  /// Default to using the package assets so it "just works"
  static AssetProvider assetProvider = const PackageAssetProvider();

  /// Optional: override from the host app if needed
  static void setAssetProvider(AssetProvider provider) {
    assetProvider = provider;
  }
}
