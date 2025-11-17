import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/dashboard_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/home_page_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/dashboard/controller/settings_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<HomePageController>(() => HomePageController());

    Get.appendTranslations({
      'pt_BR': {
        // Persistent Tab View
        'atalhos' : 'Atalhos',
        'servicos' : 'Serviços',
        'configuracoes' : 'Configurações',
        // Tela atalhos
        'boas-vindas' : 'Bem-vindo ao novo',
        'em_desenvolvimento': 'Aplicativo em desenvolvimento',
        'trab_constante': 'Estamos trabalhando constantemente para oferecer a melhor experiência possível. Aguarde as próximas atualizações!',
        'versao': 'Versão',
        // Tela Configuracoes
        'sobre' : 'Sobre',
        'sobre_descricao' : 'Detalhes do aplicativo',
        'ling_descricao' : 'Alterar idioma do aplicativo',
        'sair' : 'Sair',
        'sair_descricao' : 'Entrar como outro usuário'
      },
      'en_US': {
        // Persistent Tab View
        'atalhos' : 'Shortcuts',
        'servicos' : 'Services',
        'configuracoes' : 'Settings',
        // Tela atalhos
        'boas-vindas' : 'Welcome to the new',
        'em_desenvolvimento': 'App under development',
        'trab_constante': 'We are constantly working to deliver the best possible experience. Look forward to the next updates!',
        'versao': 'Version',
        // Tela Configuracoes
        'sobre' : 'About',
        'sobre_descricao' : 'Application details',
        'ling_descricao' : 'Change App language',
        'sair' : 'Logout',
        'sair_descricao' : 'Log in as a different user'
      },
      'it_IT': {
        // Persistent Tab View
        'atalhos' : 'Scorciatoie',
        'servicoes' : 'Servizi',
        'configuracoes' : 'Impostazioni',
        // Tela Configuracoes
        'sobre' : 'Informazioni',
        'sobre_descricao' : 'Dettagli dell\'app',
        'ling_descricao' :  'Cambia la lingua dell\'app',
        'sair' :  'Esci',
      }
    });
  }
}
