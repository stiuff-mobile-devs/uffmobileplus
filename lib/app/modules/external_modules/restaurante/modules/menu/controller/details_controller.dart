import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/menu/controller/restaurants_controller.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' as intl;
import '../data/models/campus_model.dart';
import '../data/models/meal_model.dart';
import 'menu_controller.dart';

class _TextFieldData {
  final String text;
  final double fontSize;
  final double offsetY;
  final bool bold;
  final double? customWidth;

  _TextFieldData(this.text, this.fontSize, this.offsetY,
      [this.bold = false, this.customWidth]);
}

class DetailsController extends GetxController {
  final RestaurantsController restaurantsController =
      Get.find<RestaurantsController>();
  MenuListController menuListController = Get.find<MenuListController>();

  Future<void> _deleteTemporaryImages() async {
    final tempDir = await getTemporaryDirectory();
    final directory = Directory(tempDir.path);

    if (directory.existsSync()) {
      directory.listSync().forEach((file) {
        if (file is File && file.path.endsWith('.png')) {
          file.deleteSync();
        }
      });
    }
  }

  @override
  void dispose() {
    _deleteTemporaryImages();
    super.dispose();
  }

  Future<void> shareImage(MealModel meal) async {
    DateTime data = DateTime.parse(meal.createdAt.toString());
    String formattedDate = intl.DateFormat('yyyy-MM-dd_HH:mm:ss').format(data);

    var imgId = (meal.id as int) + 918323;

    final tempDir = await getTemporaryDirectory();
    final filePath = ('${tempDir.path}/SharedMenu_${formattedDate}_$imgId.png');
    if (await File(filePath).exists()) {
      await Share.shareXFiles([XFile(filePath)],
          text:
              'Confira o cardápio do RU da UFF! Para mais informações, baixe o UFF Mobile Plus (disponível para Android e iOS).');
    } else {
      debugPrint("File does NOT exist!");
    }
  }

  void _applyColorFilter(img.Image image, Color mealColor) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Color color = image.getPixel(x, y);

        // double inAlpha = mealColor.alpha / 255;
        double inRed = mealColor.red / 255;
        double inGreen = mealColor.green / 255;
        double inBlue = mealColor.blue / 255;

        double alpha = color.getChannel(img.Channel.alpha).toDouble();
        double red = color.getChannel(img.Channel.red).toDouble();
        double green = color.getChannel(img.Channel.green).toDouble();
        double blue = color.getChannel(img.Channel.blue).toDouble();

        double newRed, newGreen, newBlue;

        if (red <= 100 && green <= 100 && blue <= 100) {
          newRed = 0;
          newGreen = 0;
          newBlue = 0;
        } else {
          newRed = (red * inRed + 50).clamp(0, 255);
          newGreen = (green * inGreen + 50).clamp(0, 255);
          newBlue = (blue * inBlue + 50).clamp(0, 255);
        }

        img.Color newColor =
            img.ColorFloat32.rgba(newRed, newGreen, newBlue, alpha);

        image.setPixel(x, y, newColor);
      }
    }
  }

  TextPainter _drawTextField(String txt, double fontSize, bool isBold,
      double width, double height, double scale, Canvas canvas) {
    final textField = TextPainter(
      text: TextSpan(
        text: txt,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize * scale,
          fontWeight: (isBold) ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Jost',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textField.layout(maxWidth: width * scale / 1.15);
    return textField;
  }

  Future<ui.Image> _createTextOverImage(img.Image originalImage, MealModel meal,
      double scale, double width, double height, String fontFamily) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0, 0), Offset(width * scale, height * scale)));

    final backgroundUiImage =
        await _resizeAndConvertToUIImage(originalImage, width, height, scale);

    canvas.drawImage(backgroundUiImage, const Offset(0, 0), Paint());

    DateTime data = DateTime.parse(meal.date.toString());

    final hasSideIngr = (meal.sideIngr!.length <= 1) ? -20 : 0;

    final hasMainIngr = (meal.mainIngr!.length <= 1) ? -20 : 0;

    final hasGarnishIngr = (meal.garnishIngr!.length <= 1) ? -20 : 0;

    final textFields = [
      _TextFieldData(
          '${menuListController.getDayOfWeek(data.weekday)} | ${data.day}/${data.month}/${data.year}',
          10,
          13 * scale),
      _TextFieldData(
          Campus.getName(meal.campus!).toUpperCase(), 19, 42.5 * scale, true),
      _TextFieldData('CARDÁPIO do:', 16, 82.5 * scale),
      _TextFieldData(
          data.hour == 12 || (data.hour == 11 && data.minute == 15)
              ? 'ALMOÇO'
              : 'JANTAR',
          16,
          102.5 * scale,
          true),
      _TextFieldData('PRATO PRINCIPAL:', 10, (132.5) * scale),
      _TextFieldData(meal.main!.toUpperCase(), 10, (147.5) * scale, true),
      _TextFieldData(meal.mainIngr!, 9, (162.5) * scale),
      _TextFieldData('GUARNIÇÃO:', 10, (202.5 + hasMainIngr) * scale),
      _TextFieldData(
          meal.garnish!.toUpperCase(), 10, (217.5 + hasMainIngr) * scale, true),
      _TextFieldData(meal.garnishIngr!, 9, (232.5 + hasMainIngr) * scale),
      _TextFieldData('ACOMPANHAMENTO:', 10,
          (272.5 + hasGarnishIngr + hasMainIngr) * scale),
      _TextFieldData(meal.side!.toUpperCase(), 10,
          (287.5 + hasGarnishIngr + hasMainIngr) * scale, true),
      _TextFieldData(
          meal.sideIngr!, 9, (302.5 + hasGarnishIngr + hasMainIngr) * scale),
      _TextFieldData(
          'SALADA 1:',
          10,
          (342.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale,
          false,
          width / 2),
      _TextFieldData(
          meal.salad1!.toUpperCase(),
          10,
          (357.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale,
          true,
          width / 2),
      _TextFieldData(
          'SALADA 2:',
          10,
          (342.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale,
          false,
          width * 3 / 2),
      _TextFieldData(
          meal.salad2!.toUpperCase(),
          10,
          (357.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale,
          true,
          width * 3 / 2),
      _TextFieldData('SOBREMESA:', 10,
          (387.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale),
      _TextFieldData(meal.dessert!.toUpperCase(), 10,
          (402.5 + hasSideIngr + hasMainIngr + hasGarnishIngr) * scale, true),
      _TextFieldData(meal.observ!.toUpperCase(), 10, 426.5 * scale, true),
      _TextFieldData('Cardápio sujeito a alterações.', 9, 471.5 * scale)
    ];

    for (var field in textFields) {
      final textField = _drawTextField(
        field.text,
        field.fontSize,
        field.bold,
        field.customWidth ?? width,
        height,
        scale,
        canvas,
      );
      textField.paint(
          canvas,
          Offset((field.customWidth ?? width) * scale / 2 - textField.width / 2,
              field.offsetY));
    }

    final picture = recorder.endRecording();
    final imag = await picture.toImage(
        (width * scale).toInt(), (height * scale).toInt());
    return imag;
  }

  Future<ui.Image> _resizeAndConvertToUIImage(
      img.Image image, double width, double height, double scale) async {
    final resizedImage = img.copyResize(image,
        width: (width * scale).toInt(), height: (height * scale).toInt());
    final byteData = Uint8List.fromList(img.encodePng(resizedImage));
    return await decodeImageFromList(byteData);
  }

  Future<List<int>> createMealMenuVisualizer(MealModel meal) async {
    DateTime mData = DateTime.parse(meal.createdAt.toString());
    String formattedDate = intl.DateFormat('yyyy-MM-dd_HH:mm:ss').format(mData);

    // Provavelmente não é a melhor forma de fazer isso, mas...
    var imgId = (meal.id as int) + 918323;

    final tempDir = await getTemporaryDirectory();
    final filePath = ('${tempDir.path}/SharedMenu_${formattedDate}_$imgId.png');

    if (await File(filePath).exists()) {
      return File(filePath).readAsBytesSync();
    } else {
      debugPrint("File does NOT exist! Initializing Canvas...");
    }

    ByteData data =
        await rootBundle.load('assets/modules/restaurant/menu_template.png');
    Uint8List bytes = data.buffer.asUint8List();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Não foi possível decodificar a imagem.');
    }

    if (meal.open != 0) {
      _applyColorFilter(originalImage, Campus.getColor(meal.campus!));
    }

    const scale = 4.0;

    final uiImage = await _createTextOverImage(
      originalImage,
      meal,
      scale,
      282.5,
      498,
      'Jost',
    );

    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final bufferImg = byteData!.buffer.asUint8List();

    final file = await File(filePath).create();

    await file.writeAsBytes(bufferImg);

    return bufferImg;
  }
}
