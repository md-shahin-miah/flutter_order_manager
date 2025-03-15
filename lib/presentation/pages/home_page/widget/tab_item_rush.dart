import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/presentation/pages/home_page/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildTabRush(String title, int count, ThemeData theme, int index, bool rushMode) {
  return Consumer(builder: (context, ref, child) {
    final selectedIndex = ref.watch(selectTabProvider);

    return Expanded(
      child: InkWell(
        onTap: () {
          DefaultTabController.of(context).index = index;
          ref.read(selectTabProvider.notifier).state = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedIndex == index ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedIndex == index ? theme.colorScheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selectedIndex == index ? AppColors.colorWhite : AppColors.textLight,

                ),
              ),

              Text(
                ' 0',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selectedIndex == index ? AppColors.colorWhite : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}
