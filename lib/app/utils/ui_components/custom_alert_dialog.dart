import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uffmobileplus/app/ui/widgets/responsive_uff_logo.dart';

AwesomeDialog customAlertDialog(BuildContext ctx,
  {String? title,
  String? desc,
  String? imageUrl,
  Function()? onConfirm,
  Function()? onCancel,
  String? btnConfirmText,
  String? btnCancelText,
  Color? btnConfirmColor,
  bool headerAnimationLoop = false,
  AnimType animType = AnimType.scale,
  DialogType dialogType = DialogType.infoReverse,
  bool dismissOnTouchOutside = true,
  bool dismissOnBackKeyPress = true,
  bool autoDismiss = true,
  dynamic Function(DismissType)? onDismissCallback}) {
    if (imageUrl == null) {
      return AwesomeDialog(
        context: ctx,
        title: title,
        desc: desc,
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: btnConfirmText,
        btnCancelText: btnCancelText,
        btnOkColor: btnConfirmColor,
        headerAnimationLoop: headerAnimationLoop,
        animType: animType,
        dialogType: dialogType,
        dismissOnTouchOutside: dismissOnTouchOutside,
        dismissOnBackKeyPress: dismissOnBackKeyPress,
        autoDismiss: autoDismiss,
        onDismissCallback: onDismissCallback);
    } else {
      return AwesomeDialog( // Corpo customizado com imagem
        context: ctx,
        body: Column(children: [
          Text(
            title!,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          imageUrl.isNotEmpty ? Image.network(
            imageUrl,
            height: 120,
          ) : const SizedBox(height: 10),
        ]),
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: btnConfirmText,
        btnCancelText: btnCancelText,
        btnOkColor: btnConfirmColor,
        headerAnimationLoop: headerAnimationLoop,
        animType: animType,
        dialogType: dialogType,
        dismissOnTouchOutside: dismissOnTouchOutside,
        dismissOnBackKeyPress: dismissOnBackKeyPress,
        autoDismiss: autoDismiss,
        onDismissCallback: onDismissCallback
      );
    }
  // return AlertDialog(
  //   title: Text("page_under_development".tr,
  //     style: TextStyle(color: Colors.white),),
  //   // content: Text("under_development".tr,
  //   //   style: TextStyle(color: Colors.white),),
  //   backgroundColor: AppColors.darkBlue(),
  //   actions: [
  //     Center(
  //       child: TextButton(onPressed: () {
  //         Get.back();
  //       }, child: const Text("OK")),
  //     )
  //   ],
  // );
  }

AwesomeDialog idUffAlertDialog(BuildContext ctx,
    {String? title,
        String? desc,
        Function()? onConfirm,
        Function()? onCancel,
        String? btnConfirmText,
        String? btnCancelText,
        Color? btnConfirmColor,
        bool headerAnimationLoop = false,
        AnimType animType = AnimType.scale,
        DialogType dialogType = DialogType.infoReverse,
        bool dismissOnTouchOutside = true,
        bool dismissOnBackKeyPress = true,
        bool autoDismiss = true,
        dynamic Function(DismissType)? onDismissCallback}) {
    return AwesomeDialog(
        customHeader: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                // color: Colors.black12,
                shape: BoxShape.circle,
            ),
            child: Center(
                child: ResponsiveUffLogo(height: 45),
            ),
        ),
        context: ctx,
        title: title,
        desc: desc,
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: btnConfirmText,
        btnCancelText: btnCancelText,
        btnOkColor: btnConfirmColor,
        headerAnimationLoop: headerAnimationLoop,
        animType: animType,
        dialogType: dialogType,
        dismissOnTouchOutside: dismissOnTouchOutside,
        dismissOnBackKeyPress: dismissOnBackKeyPress,
        autoDismiss: autoDismiss,
        onDismissCallback: onDismissCallback);
}

AwesomeDialog googleAlertDialog(BuildContext ctx,
    {String? title,
        String? desc,
        Function()? onConfirm,
        Function()? onCancel,
        String? btnConfirmText,
        String? btnCancelText,
        Color? btnConfirmColor,
        bool headerAnimationLoop = false,
        AnimType animType = AnimType.scale,
        DialogType dialogType = DialogType.infoReverse,
        bool dismissOnTouchOutside = true,
        bool dismissOnBackKeyPress = true,
        bool autoDismiss = true,
        dynamic Function(DismissType)? onDismissCallback}) {
    return AwesomeDialog(
        customHeader: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                // color: Colors.black12,
                shape: BoxShape.circle,
            ),
            child: Center(
                child: Image.asset("assets/logos/google_colorido.png", height: 65),
            ),
        ),
        context: ctx,
        title: title,
        desc: desc,
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: btnConfirmText,
        btnCancelText: btnCancelText,
        btnOkColor: btnConfirmColor,
        headerAnimationLoop: headerAnimationLoop,
        animType: animType,
        dialogType: dialogType,
        dismissOnTouchOutside: dismissOnTouchOutside,
        dismissOnBackKeyPress: dismissOnBackKeyPress,
        autoDismiss: autoDismiss,
        onDismissCallback: onDismissCallback);
}

void dismissCustomAlertDialog(BuildContext ctx) {
  AwesomeDialog(context: ctx).dismiss();
}
