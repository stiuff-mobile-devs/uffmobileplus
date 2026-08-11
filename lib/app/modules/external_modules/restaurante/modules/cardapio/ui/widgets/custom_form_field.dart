import 'package:flutter/material.dart';
import '../../../../../../../utils/color_pallete.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController primaryController;
  final String titulo;
  final String artigo;
  final int primaryMaxLength;
  final bool hasManyLines;
  final bool isDetailed;
  final int secondaryMaxLength;
  final TextEditingController? secondaryController;
  final Animation<double> heightAnimation;
  final Animation<Offset> offsetAnimation;
  final bool showDetails;
  final AnimationController controller;
  final String? primaryInitValue;
  final String? secondaryInitValue;
  final bool? allowNull;

  CustomFormField({
    super.key,
    this.primaryInitValue,
    this.secondaryInitValue,
    required this.primaryController,
    required this.titulo,
    required this.artigo,
    required this.primaryMaxLength,
    this.hasManyLines = false,
    this.isDetailed = false,
    this.secondaryMaxLength = 252,
    this.secondaryController,
    required this.heightAnimation,
    required this.offsetAnimation,
    required this.showDetails,
    required this.controller,
    this.allowNull,
  }) {
    if (primaryInitValue != null) {
      primaryController.text = primaryInitValue!;
    }
    if (secondaryController != null && secondaryInitValue != null) {
      secondaryController!.text = secondaryInitValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showDetails) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: Border(bottom: BorderSide()),
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: primaryController,
                maxLines: (hasManyLines ? null : 1),
                minLines: 1,
                maxLength: primaryMaxLength,
                keyboardType: (hasManyLines
                    ? TextInputType.multiline
                    : TextInputType.text),
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.darkBlue(),
                ),
                decoration: InputDecoration(
                  hintText: 'Informe $artigo $titulo',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 0.0),
                  labelText: titulo,
                  labelStyle: TextStyle(color: AppColors.mediumBlue()),
                ),
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: Text(
                      '$currentLength / $maxLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkBlue(),
                      ),
                    ),
                  );
                },
                validator: (value) {
                  if (allowNull == true) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return 'Informe $artigo $titulo';
                  }
                  return null;
                },
                cursorColor: AppColors.darkBlue(),
              ),
            ),
            SizeTransition(
              sizeFactor: heightAnimation,
              axis: Axis.vertical,
              child: SlideTransition(
                position: offsetAnimation,
                child: (isDetailed)
                    ? Column(
                        key: ValueKey<bool>(isDetailed),
                        children: [
                          const SizedBox(
                            height: 1,
                            child: Divider(
                              indent: 0,
                              height: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: secondaryController,
                              maxLines: null,
                              minLines: 1,
                              maxLength: secondaryMaxLength,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColors.darkBlue(),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Informe os ingredientes d$artigo $titulo',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 0.0),
                                labelText: 'Ingredientes d$artigo $titulo',
                                labelStyle:
                                    TextStyle(color: AppColors.darkBlue()),
                              ),
                              validator: (value) {
                                if (allowNull == true) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Informe os ingredientes d$artigo $titulo';
                                }
                                return null;
                              },
                              buildCounter: (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  child: Text(
                                    '$currentLength / $maxLength',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkBlue(),
                                    ),
                                  ),
                                );
                              },
                              cursorColor: AppColors.darkBlue(),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
