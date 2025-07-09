import 'package:flutter/foundation.dart';
import 'package:my_app/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // <<--- ต้องมีบรรทัดนี้ !!!

class UserData {
  final ValueNotifier<String> weightNotifier = ValueNotifier<String>("n/a");
  final ValueNotifier<String> heightNotifier = ValueNotifier<String>("n/a");
  final ValueNotifier<String> bmiNotifier = ValueNotifier<String>("n/a");
  final ValueNotifier<String> bmiStatusNotifier = ValueNotifier<String>("");

  final ValueNotifier<List<FoodItem>> foodItemsNotifier =
      ValueNotifier<List<FoodItem>>([]);
  final ValueNotifier<double> totalProteinNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> totalFatNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> totalCarbohydrateNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> totalCaloriesNotifier = ValueNotifier<double>(0.0);

  String get weight => weightNotifier.value;
  String get height => heightNotifier.value;
  String get bmi => bmiNotifier.value;
  String get bmiStatus => bmiStatusNotifier.value;

  UserData() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    weightNotifier.value = prefs.getString('weight') ?? "n/a";
    heightNotifier.value = prefs.getString('height') ?? "n/a";
    bmiNotifier.value = prefs.getString('bmi') ?? "n/a";
    bmiStatusNotifier.value = prefs.getString('bmiStatus') ?? "";

    totalProteinNotifier.value = prefs.getDouble('totalProtein') ?? 0.0;
    totalFatNotifier.value = prefs.getDouble('totalFat') ?? 0.0;
    totalCarbohydrateNotifier.value = prefs.getDouble('totalCarbohydrate') ?? 0.0;
    totalCaloriesNotifier.value = prefs.getDouble('totalCalories') ?? 0.0;

    final String? foodItemsJson = prefs.getString('foodItems');
    if (foodItemsJson != null && foodItemsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedList = json.decode(foodItemsJson) as List;
        // ตรวจสอบว่า FoodItem.fromJson ถูกเรียกใช้และส่งค่าที่ถูกต้อง
        foodItemsNotifier.value = decodedList.map((item) => FoodItem.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding food items: $e');
        }
        foodItemsNotifier.value = []; // เคลียร์ข้อมูลหากถอดรหัสล้มเหลว
      }
    } else {
      foodItemsNotifier.value = [];
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', weightNotifier.value);
    await prefs.setString('height', heightNotifier.value);
    await prefs.setString('bmi', bmiNotifier.value);
    await prefs.setString('bmiStatus', bmiStatusNotifier.value);

    await prefs.setDouble('totalProtein', totalProteinNotifier.value);
    await prefs.setDouble('totalFat', totalFatNotifier.value);
    await prefs.setDouble('totalCarbohydrate', totalCarbohydrateNotifier.value);
    await prefs.setDouble('totalCalories', totalCaloriesNotifier.value);

    final List<Map<String, dynamic>> jsonList = foodItemsNotifier.value.map((item) => item.toJson()).toList();
    await prefs.setString('foodItems', json.encode(jsonList));
  }

  void updateData({
    String? newWeight,
    String? newHeight,
    String? newBmi,
    String? newBmiStatus,
  }) {
    if (newWeight != null) weightNotifier.value = newWeight;
    if (newHeight != null) heightNotifier.value = newHeight;
    if (newBmi != null) bmiNotifier.value = newBmi;
    if (newBmiStatus != null) bmiStatusNotifier.value = newBmiStatus;
    _saveData();
  }

  void addFoodItem(FoodItem item) {
    final currentList = List<FoodItem>.from(foodItemsNotifier.value);
    currentList.add(item);
    foodItemsNotifier.value = currentList;
    _calculateTotalMacros();
    _saveData();
  }

  void removeFoodItem(FoodItem item) {
    final currentList = List<FoodItem>.from(foodItemsNotifier.value);
    // เพิ่มเงื่อนไขการลบให้เฉพาะเจาะจงมากขึ้น เพื่อหลีกเลี่ยงการลบเมนูชื่อซ้ำกัน
    currentList.removeWhere((element) => element.name == item.name &&
                                        element.meatType == item.meatType &&
                                        element.meatAmount == item.meatAmount &&
                                        element.riceAmount == item.riceAmount &&
                                        element.protein == item.protein &&
                                        element.fat == item.fat &&
                                        element.carbohydrate == item.carbohydrate &&
                                        element.calories == item.calories);
    foodItemsNotifier.value = currentList;
    _calculateTotalMacros();
    _saveData();
  }

  void _calculateTotalMacros() {
    double protein = 0;
    double fat = 0;
    double carbohydrate = 0;
    double calories = 0;

    for (var item in foodItemsNotifier.value) {
      protein += item.protein;
      fat += item.fat;
      carbohydrate += item.carbohydrate;
      calories += item.calories;
    }

    totalProteinNotifier.value = protein;
    totalFatNotifier.value = fat;
    totalCarbohydrateNotifier.value = carbohydrate;
    totalCaloriesNotifier.value = calories;
  }
}