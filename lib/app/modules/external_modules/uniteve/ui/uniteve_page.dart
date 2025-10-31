import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:url_launcher/link.dart';

class UnitevePage extends StatelessWidget {
  const UnitevePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unitevê"),
        centerTitle: true,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient()
        ),
        child: Column(
          children: [
            FooterWidget()
          ],
        ),
      ),
      bottomNavigationBar: FooterWidget(),

    );
  }
}

class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Link(
          uri: Uri.parse('https://pt-br.facebook.com/uniteveuff/'), 
          builder: (_, link) => IconButton(
            onPressed: link, 
            icon: SvgPicture.asset('assets/icons/circle_facebook.svg')
          )
        ),
        Link(
          uri: Uri.parse('https://www.instagram.com/uniteveuff/'), 
          builder: (_, link) => IconButton(
            onPressed: link, 
            icon: SvgPicture.asset('assets/icons/circle_instagram.svg')
          )
        ),
        Link(
          uri: Uri.parse('https://www.youtube.com/user/uniteveuff'), 
          builder: (_, link) => IconButton(
            onPressed: link, 
            icon: SvgPicture.asset('assets/icons/circle_youtube.svg')
          )
        )
      ],
    );
  }

}
