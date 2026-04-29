import 'package:flutter/material.dart';

class NasikoNavigationListItem extends StatelessWidget {
  const NasikoNavigationListItem({super.key, required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(item.label), onTap: item.onTap);
  }
}
