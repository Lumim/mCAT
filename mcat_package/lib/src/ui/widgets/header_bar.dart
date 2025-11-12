import 'package:flutter/material.dart';
import 'step_indicator.dart';
import 'package:mcat_package/src/services/asset_provider.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? activeStep;
  final int totalSteps;
  final bool showCloseButton;
  final AssetProvider assetProvider;

  const HeaderBar({
    super.key,
    required this.title,
    this.activeStep,
    this.totalSteps = 5,
    this.showCloseButton = true,
    this.assetProvider = const PackageAssetProvider(),
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Image.asset(
              assetProvider.logo,
              package: 'mcat_package',
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 80),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: activeStep != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: StepIndicator(activeIndex: activeStep!, total: totalSteps),
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(activeStep != null ? 90 : kToolbarHeight);
}
