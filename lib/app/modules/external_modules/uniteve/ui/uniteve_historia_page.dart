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
                'A Unitevê',
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
                    'A Unitevê foi criada originariamente como um canal de televisão a cabo gerido pela Universidade Federal Fluminense e deu inicio às suas transmissões no mês de dezembro de 2000 a partir do Instituto de Arte e Comunicação Social (IACS), com o apoio da Superintendência de Tecnologia da Informação (STI) e da operadora da TV a cabo, nas cidades de Niterói e São Gonçalo. Com a suspensão das atividades da operadora responsável pela distribuição do sinal, seu conteúdo é atualmente disponibilizado através do Youtube e redes sociais. Em 2019 a Unitevê voltou a fazer parte da estrutura da Superintendência de Comunicação Social (SCS) da Universidade Federal Fluminense.',
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
