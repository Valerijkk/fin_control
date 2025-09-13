import 'package:flutter/material.dart';
import 'theme_action.dart';

class AppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool canPop;
  const AppBarTitle({super.key, required this.title, this.actions = const [], this.canPop = false});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(leading: canPop ? const BackButton() : null, title: Text(title), actions: actions);
  }
}
