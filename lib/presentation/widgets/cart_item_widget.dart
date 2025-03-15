import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:intl/intl.dart';

Widget buildItemsSection(BuildContext context, List<Item> items, ThemeData theme, bool lastViewShow) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (items.isEmpty)
        Text('No items', style: theme.textTheme.bodyMedium)
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildItemCard(item, theme, context, index, items.length, lastViewShow);
          },
        ),
    ],
  );
}

Widget _buildItemCard(Item item, ThemeData theme, BuildContext context, int index, int length, bool lastViewShow) {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.quantity} x ${item.name}',
              style: theme.textTheme.titleMedium?.copyWith(),
            ),
          ),
        ],
      ),
      if (item.subItems.isNotEmpty) ...[
        ...item.subItems.map((subItem) => Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 2),
              child: Row(
                children: [
                  Text(
                    subItem.name,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )),
      ],
      index != length - 1
          ? Container(
              margin: EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width - 50,
              height: 1,
              color: AppColors.greyLight,
            )
          : lastViewShow
              ? Container(
                  margin: EdgeInsets.only(top: 8),
                  width: MediaQuery.of(context).size.width - 50,
                  height: 1,
                  color: AppColors.greyLight,
                )
              : SizedBox(),
      SizedBox(
        height: 10,
      )
    ],
  );
}
