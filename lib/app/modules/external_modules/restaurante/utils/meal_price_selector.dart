import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_prices.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/utils/meal_simulation_banner.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

/// Botão da AppBar que troca o valor por refeição mostrado nas telas do RU
/// (0,70 / 14,50). Fica âmbar enquanto o valor não é o do perfil.
Widget mealPriceAppBarAction({
  required double selected,
  required double? profilePrice,
  required ValueChanged<double> onChanged,
}) {
  final simulating = profilePrice != null && selected != profilePrice;
  return IconButton(
    icon: Icon(
      Icons.price_change_outlined,
      color: simulating ? kMealSimulationColor : Colors.white,
    ),
    tooltip: 'ru_ver_valores_para'.tr,
    onPressed: () => pickMealPrice(
      selected: selected,
      profilePrice: profilePrice,
      onChanged: onChanged,
    ),
  );
}

/// Pop-up para escolher o valor mostrado. Ao trocar, avisa a mudança.
Future<void> pickMealPrice({
  required double selected,
  required double? profilePrice,
  required ValueChanged<double> onChanged,
}) async {
  final picked = await AppPopups.choose<double>(
    title: 'ru_ver_valores_para'.tr,
    icon: Icons.restaurant,
    selected: selected,
    options: [
      for (final price in [MealPrices.student, MealPrices.staff])
        PopupOption<double>(
          value: price,
          label: 'R\$ ${MealPrices.format(price)}',
          description: price == profilePrice
              ? 'seu_valor'.tr
              : 'ru_por_refeicao'.tr,
        ),
    ],
  );
  if (picked == null || picked == selected) return;

  onChanged(picked);
  final value = MealPrices.format(picked);
  final simulating = profilePrice != null && picked != profilePrice;
  AppPopups.info(
    simulating
        ? 'ru_simulando'.trParams({'valor': value})
        : 'ru_valor_perfil'.trParams({'valor': value}),
  );
}
