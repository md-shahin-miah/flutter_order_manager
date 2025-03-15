import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/presentation/widgets/common/custom_button.dart';
import 'package:go_router/go_router.dart';


class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "The page you are looking for doesn't seem to exist.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  textColor: AppColors.colorWhite,
                  onPressed: () {
                    context.goBack();
                  },
                  text: 'Go Back',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      );
}
