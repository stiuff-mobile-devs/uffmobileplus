import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/color_pallete.dart';
import '../../controller/meal_form_controller.dart';
import '../../data/models/meal_model.dart';
import '../../data/repository/restaurant_repository.dart';
import 'custom_form_field.dart';
import 'custom_multi_select_dropdown.dart';

class MealFormWidget extends StatefulWidget {
  final MealModel? predefinition;
  const MealFormWidget({super.key, this.predefinition});

  @override
  State<MealFormWidget> createState() => _MealFormWidgetState();
}

class _MealFormWidgetState extends State<MealFormWidget>
    with SingleTickerProviderStateMixin {
  final MealFormController mealFormController = Get.put(MealFormController());

  final _form = GlobalKey<FormState>();
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;
  late Animation<double> heightAnimation;

  RestaurantRepository restaurantRepository = Get.find<RestaurantRepository>();

  TextEditingController principal = TextEditingController();
  TextEditingController principalIngr = TextEditingController();
  TextEditingController guarnicao = TextEditingController();
  TextEditingController guarnicaoIngr = TextEditingController();
  TextEditingController acompanhamento = TextEditingController();
  TextEditingController acompanhamentoIngr = TextEditingController();
  TextEditingController salada1 = TextEditingController();
  TextEditingController salada2 = TextEditingController();
  TextEditingController sobremesa = TextEditingController();
  TextEditingController observ = TextEditingController();

  List<String> campus = [
    'Gragoatá',
    'Praia Vermelha',
    'Reitoria',
    'Veterinária',
    'HUAP'
  ];
  List<String> selectedCampus = [];
  List<String> shifts = ['Almoço', 'Jantar'];
  List<String> selectedShifts = [];

  List<DateTime?> chosenDates = [DateTime.now()];
  String chosenDatesInString =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

  bool canCreate = true;
  bool showFrutaField = false;
  bool showSobremesaField = false;
  bool showObservacoesField = false;
  bool showDetails = false;
  bool allowNull = false;

  bool isCampusMultiSelectValid = true;
  bool isShiftMultiSelectValid = true;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    Get.delete<MealFormController>();
    animationController.dispose();
    super.dispose();
  }

  void _preencherFormulario(MealModel receivedMeal) {
    if (receivedMeal.mainIngr!.isNotEmpty ||
        receivedMeal.garnishIngr!.isNotEmpty ||
        receivedMeal.sideIngr!.isNotEmpty) {
      setState(() {
        showDetails = true;
      });
    }
    principal.text = receivedMeal.main.toString();
    principalIngr.text = receivedMeal.mainIngr.toString();
    guarnicao.text = receivedMeal.garnish.toString();
    guarnicaoIngr.text = receivedMeal.garnishIngr.toString();
    acompanhamento.text = receivedMeal.side.toString();
    acompanhamentoIngr.text = receivedMeal.sideIngr.toString();
    salada1.text = receivedMeal.salad1.toString();
    salada2.text = receivedMeal.salad2.toString();
    sobremesa.text = receivedMeal.dessert.toString();
    if (receivedMeal.observ!.isNotEmpty) {
      setState(() {
        showObservacoesField = true;
      });
    }
    observ.text = receivedMeal.observ.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _form,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 12.0, 20.0),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 4.0,
              radius: const Radius.circular(4.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 56, 7, 103),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9.0))),
                          child: CheckboxListTile(
                            title: const Text(
                              'Detalhar Campos',
                              style: TextStyle(color: Colors.white),
                            ),
                            tileColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            value: showDetails,
                            onChanged: (value) {
                              setState(() {
                                showDetails = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 56, 7, 103)
                                  .withOpacity(0.7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(9.0))),
                          child: CheckboxListTile(
                            title: const Text(
                              'Permitir Campos Nulos',
                              style: TextStyle(color: Colors.white),
                            ),
                            activeColor: const Color.fromARGB(255, 76, 23, 126),
                            tileColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            value: allowNull,
                            onChanged: (value) {
                              setState(() {
                                allowNull = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      CustomFormField(
                        primaryController: principal,
                        secondaryController: principalIngr,
                        titulo: 'Prato Principal',
                        artigo: 'o',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.main
                            : null,
                        secondaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.mainIngr
                            : null,
                        primaryMaxLength: 96,
                        isDetailed: showDetails,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      CustomFormField(
                        primaryController: guarnicao,
                        secondaryController: guarnicaoIngr,
                        titulo: 'Guarnição',
                        artigo: 'a',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.garnish
                            : null,
                        secondaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.garnishIngr
                            : null,
                        primaryMaxLength: 96,
                        isDetailed: showDetails,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      CustomFormField(
                        primaryController: acompanhamento,
                        secondaryController: acompanhamentoIngr,
                        titulo: 'Acompanhamento',
                        artigo: 'o',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.side
                            : null,
                        secondaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.sideIngr
                            : null,
                        primaryMaxLength: 96,
                        isDetailed: showDetails,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      CustomFormField(
                        primaryController: salada1,
                        titulo: 'Salada 1',
                        artigo: 'a',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.salad1
                            : null,
                        primaryMaxLength: 96,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      CustomFormField(
                        primaryController: salada2,
                        titulo: 'Salada 2',
                        artigo: 'a',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.salad2
                            : null,
                        primaryMaxLength: 96,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      CustomFormField(
                        primaryController: sobremesa,
                        titulo: 'Sobremesa',
                        artigo: 'a',
                        primaryInitValue: (widget.predefinition != null)
                            ? widget.predefinition!.dessert
                            : null,
                        primaryMaxLength: 96,
                        heightAnimation: heightAnimation,
                        offsetAnimation: offsetAnimation,
                        showDetails: showDetails,
                        allowNull: allowNull,
                        controller: animationController,
                      ),
                      (widget.predefinition == null)
                          ? const Divider()
                          : const SizedBox.shrink(),
                      (widget.predefinition == null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomMultiSelectDropdown(
                                options: shifts,
                                selectedValues: selectedShifts,
                                onChanged: (value) {
                                  setState(() {
                                    selectedShifts = value;
                                  });
                                },
                                itemLabel: (shifts) => shifts,
                                dialogTitle: 'Selecione os Turnos',
                                hintText: 'Selecione os Turnos',
                                isValid: isShiftMultiSelectValid,
                              ),
                            )
                          : const SizedBox.shrink(),
                      (widget.predefinition == null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomMultiSelectDropdown(
                                options: campus,
                                selectedValues: selectedCampus,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCampus = value;
                                  });
                                },
                                itemLabel: (campus) => campus,
                                dialogTitle: 'Selecione os Campus',
                                hintText: 'Selecione os Campus',
                                isValid: isCampusMultiSelectValid,
                              ),
                            )
                          : const SizedBox.shrink(),
                      const Divider(),
                      CheckboxListTile(
                        title: const Text('Adicionar Observações'),
                        value: showObservacoesField,
                        onChanged: (value) {
                          setState(() {
                            showObservacoesField = value!;
                          });
                        },
                      ),
                      if (showObservacoesField)
                        CustomFormField(
                          primaryController: observ,
                          titulo: 'Observações',
                          artigo: 'as',
                          primaryMaxLength: 144,
                          primaryInitValue: (observ.text.isEmpty
                              ? "*AS PREPARAÇÕES PODEM CONTER TRAÇOS DE GLÚTEN/LACTOSE"
                              : observ.text),
                          heightAnimation: heightAnimation,
                          offsetAnimation: offsetAnimation,
                          showDetails: showDetails,
                          allowNull: allowNull,
                          controller: animationController,
                          hasManyLines: true,
                        ),
                      const Divider(),
                      (widget.predefinition == null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Obx(() => ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      padding: const EdgeInsets.all(8),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: AppColors.darkBlue(),
                                        width: 1.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await mealFormController
                                          .selectDates(context);
                                    },
                                    icon: Icon(
                                      Icons.edit_calendar_outlined,
                                      color: AppColors.mediumBlue(),
                                      size: 30,
                                    ),
                                    label: Text(
                                      mealFormController
                                          .chosenDatesInString.value,
                                      style: TextStyle(
                                          color: AppColors.mediumBlue(),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )),
                            )
                          : const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: canCreate
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(15),
                                  fixedSize: const Size(double.maxFinite, 60),
                                  backgroundColor: (widget.predefinition != null
                                      ? Colors.amber[600]
                                      : AppColors.mediumBlue()),
                                  foregroundColor: AppColors.lightBlue(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  if (widget.predefinition == null) {
                                    setState(() {
                                      isCampusMultiSelectValid =
                                          (selectedCampus.isEmpty
                                              ? false
                                              : true);
                                      isShiftMultiSelectValid =
                                          (selectedShifts.isEmpty
                                              ? false
                                              : true);
                                    });
                                    if (_form.currentState!.validate() &&
                                        isCampusMultiSelectValid &&
                                        isShiftMultiSelectValid) {
                                      mealFormController.selectedCampus.value =
                                          selectedCampus;
                                      mealFormController.selectedShifts.value =
                                          selectedShifts;
                                      MealModel meal = MealModel(
                                        date: chosenDates.first,
                                        main: principal.text,
                                        mainIngr: principalIngr.text,
                                        garnish: guarnicao.text,
                                        garnishIngr: guarnicaoIngr.text,
                                        side: acompanhamento.text,
                                        sideIngr: acompanhamentoIngr.text,
                                        salad1: salada1.text,
                                        salad2: salada2.text,
                                        dessert: sobremesa.text,
                                        observ: observ.text,
                                        campus: 'None',
                                        open: 1,
                                      );
                                      await mealFormController
                                          .sendRequisition(context, meal,
                                              mealFormController.menuController)
                                          .then((value) =>
                                              Navigator.pop(context));
                                    }
                                  } else {
                                    if (_form.currentState!.validate()) {
                                      MealModel meal = MealModel(
                                        date: chosenDates.first,
                                        main: principal.text,
                                        mainIngr: principalIngr.text,
                                        garnish: guarnicao.text,
                                        garnishIngr: guarnicaoIngr.text,
                                        side: acompanhamento.text,
                                        sideIngr: acompanhamentoIngr.text,
                                        salad1: salada1.text,
                                        salad2: salada2.text,
                                        dessert: sobremesa.text,
                                        observ: observ.text,
                                        campus: 'None',
                                        open: 1,
                                      );
                                      await mealFormController
                                          .sendEditRequisition(
                                              context,
                                              meal,
                                              mealFormController.menuController
                                                  .mealsPressedOnto,
                                              mealFormController.menuController)
                                          .then((value) =>
                                              Navigator.pop(context));
                                    }
                                  }
                                },
                                icon:
                                    const Icon(Icons.send, color: Colors.white),
                                label: (widget.predefinition == null)
                                    ? (selectedCampus.length > 1 ||
                                            selectedShifts.length > 1 ||
                                            mealFormController
                                                    .chosenDates.length >
                                                1)
                                        ? const Text(
                                            'Enviar Refeições',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400),
                                          )
                                        : const Text(
                                            'Enviar Refeição',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400),
                                          )
                                    : (mealFormController.menuController
                                                .mealsPressedOnto.length >
                                            1)
                                        ? Text(
                                            'Alterações Refeições [${mealFormController.menuController.mealsPressedOnto.length}]',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400),
                                          )
                                        : const Text(
                                            'Alterar Refeição',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400),
                                          ),
                              )
                            : const CircularProgressIndicator(
                                color: Colors.amber,
                              ),
                      ),
                      const SizedBox(height: 65),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
