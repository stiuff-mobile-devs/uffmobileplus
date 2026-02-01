import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/controller/user_data_controller.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';
import 'package:uffmobileplus/app/utils/uff_bond_ids.dart';

class ExternalModulesController extends GetxController {
  ExternalModulesController();

  late UserDataController _userDataController;
  late UserData _usermodel;

  final RxList<ExternalModules> externalModulesList = RxList([
  ExternalModules(
    iconSrc: 'assets/carteirinha_digital/icons/carteirinha.svg',
    subtitle: 'carteirinha_digital'.tr,
    page: Routes.CARTEIRINHA_DIGITAL,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/bandejapp.svg',
    subtitle: 'restaurante'.tr,
    page: Routes.RESTAURANT_MODULES,
    url: '',
    interrogation: false,
    availableFor: everyone,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/plano.svg',
    subtitle: 'plano_estudos'.tr,
    page: Routes.STUDY_PLAN,
    url: '',
    interrogation: false,
    availableFor: [ProfileTypes.grad, ProfileTypes.pos],
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/radio/icons/radio.svg',
    subtitle: 'radio_pop_goiaba'.tr,
    page: Routes.RADIO,
    url: '',
    interrogation: false,
    availableFor: everyone,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/historico.svg',
    subtitle: 'Histórico',
    page: Routes.HISTORICO,
    url: '',
    interrogation: false,
    availableFor: [ProfileTypes.grad, ProfileTypes.pos],
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/papers/icons/pesquisas.svg',
    subtitle: 'periodicos'.tr,
    page: Routes.PAPERS,
    url: '',
    interrogation: false,
    availableFor: everyone,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/uniteve.svg',
    subtitle: 'Unitevê',
    page: Routes.UNITEVE,
    url: '',
    interrogation: false,
    availableFor: everyone,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/monitora_uff.png',
    subtitle: 'monitora_uff'.tr,
    page: Routes.MONITORA_UFF,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  
  ExternalModules(
    iconSrc: 'assets/icons/ead.svg',
    subtitle: 'ead'.tr,
    page: Routes.EAD,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/repositorio_uff.svg',
    subtitle: 'repositorio_institucional'.tr,
    page: Routes.REPOSITORIO_INSTITUCIONAL,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/internacional.svg',
    subtitle: 'internacional'.tr,
    page: Routes.INTERNACIONAL,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/sos.svg',
    subtitle: 'sos'.tr,
    page: Routes.SOS,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),

  ExternalModules(
    iconSrc: 'assets/icons/atendimento.svg',
    subtitle: 'central_de_atendimento'.tr,
    page: Routes.CENTRAL_DE_ATENDIMENTO,
    url: '',
    interrogation: false,
    availableFor: everyoneLogged,
    gdiGroups: null,
  ),
]);