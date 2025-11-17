import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/uniteve/controller/uniteve_controller.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';

class UniteveContatoPage extends GetView<UniteveController> {
  const UniteveContatoPage({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8,),
              ListTile(
                leading: Icon(
                  Icons.call, 
                  size: 48.0,
                  color: Colors.white,
                ),
                title: Text(
                        'Telefone',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                subtitle: Text(
                  '(21) 2629-9665 (desativado)',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: 16,),
              ListTile(
                leading: Icon(
                  Icons.email, 
                  size: 48.0,
                  color: Colors.white,
                ),
                title: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                subtitle: Text(
                  'producao.uniteve.scs@id.uff.br',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: 16,),
              ListTile(
                leading: Icon(
                  Icons.location_on, 
                  size: 48.0,
                  color: Colors.white,
                ),
                title: Text(
                        'Endereço',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                subtitle: Text(
                  'Rua Presidente Pedreira, 62 - Ingá, Niterói/RJ 2° Andar do Prédio da Faculdade de Direito da UFF',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
