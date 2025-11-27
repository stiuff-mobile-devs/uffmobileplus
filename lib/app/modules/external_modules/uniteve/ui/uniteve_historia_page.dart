import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/controller/uniteve_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class UniteveHistoriaPage extends GetView<UniteveController> {
  const UniteveHistoriaPage({super.key});

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
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: Column(
            children: [
              SizedBox(height: 16,),
              SvgPicture.asset(
                'assets/images/logo_uniteve.svg',
                width: (MediaQuery.sizeOf(context).width)*0.5,
              ),
              SizedBox(height: 16,),
              Text(
                'a_uniteve'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16,),
              Center(
                child: Container(
                  width: MediaQuery.sizeOf(context).width*0.9,
                  child: Text(
                    'uniteve_historia_descricao'.tr,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      ),
                    ),
                ),
              ),
              SizedBox(height: 16,),
              /*ElevatedButton(
                onPressed: () => print('oi'), 
                child: Text('Saiba mais'),
              ),
              SizedBox(height: 16,),*/
            ],
          ),
        ),
      ),
    );
  }
}
