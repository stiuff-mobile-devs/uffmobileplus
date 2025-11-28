import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:uffmobileplus/app/utils/translations/en_US/en_us_translation.dart';
import 'package:uffmobileplus/app/utils/translations/it_IT/it_it_translation.dart';
import 'package:uffmobileplus/app/utils/translations/pt_BR/pt_br_translation.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'pt_BR' : ptBR,
    'en_US' : enUS,
    'it_IT' : itIT,
  };
}