import 'package:flutter/material.dart';
import 'nav_state.dart';

class NavRoute {
  NavRoute({required this.path, required this.builder});
  final String path;
  final Widget Function(BuildContext context, NavState state) builder;
}
