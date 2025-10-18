import 'package:flutter/material.dart';
import '../color_pallete.dart';

Widget customSliverAppBar(
    String title,
    { bool centerTitle = true,
      bool automaticallyImplyLeading = true,
      double elevation = 8,
      double borderRadius = 14,
      bool pinned = true,
      bool floating = false,
      bool snap = false,
      bool stretch = false,
      List<Widget>? actions
    }) {
  return SliverAppBar(
    automaticallyImplyLeading: automaticallyImplyLeading,
    title: Text(title),
    centerTitle: centerTitle,
    elevation: elevation,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius))),
    backgroundColor: AppColors.darkBlue(),
    foregroundColor: Colors.white,
    pinned: pinned,
    floating: floating,
    snap: snap,
    stretch: stretch,
    actions: actions,
  );
}

AppBar customAppBar(String title,{double borderRadius = 14, List<Widget>? actions, PreferredSizeWidget? bottom}){
  return AppBar(
    foregroundColor: Colors.white,
    title: Text(title,),
    centerTitle: true,
    automaticallyImplyLeading: true,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius))),
    backgroundColor: AppColors.darkBlue(),
    actions: actions,
    bottom: bottom,
  );
}