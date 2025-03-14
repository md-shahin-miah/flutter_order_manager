import 'package:flutter/material.dart';

class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double heightFactor = 0.5,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomBottomSheetContainer(
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }
}

class _CustomBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;

  const _CustomBottomSheetContainer({
    Key? key,
    required this.child,
    required this.heightFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

