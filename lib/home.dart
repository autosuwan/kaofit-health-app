import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_data.dart';
import 'package:my_app/models/food_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserData _userData = UserData();

  final TextEditingController _weightInputController = TextEditingController();
  final TextEditingController _heightInputController = TextEditingController();

  // Controllers for Food Input
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _riceAmountController = TextEditingController();
  final TextEditingController _meatAmountController =
      TextEditingController(); // NEW: Controller for meat amount
  String?
  _selectedMeatType; // Changed to nullable String, initial value is null

  int _touchedDonutSectionIndex = -1; // For Donut Chart Touch Interaction

  // BMI Calculation function (unchanged)
  void _calculateAndSetBMI() {
    final double? weight = double.tryParse(_weightInputController.text);
    final double? height = double.tryParse(_heightInputController.text);

    if (weight != null && height != null && height > 0) {
      final double heightInMeters = height / 100;
      final double bmi = weight / (heightInMeters * heightInMeters);
      String bmiStatus = _getBmiStatus(bmi);
      _userData.updateData(
        newBmi: bmi.toStringAsFixed(2),
        newBmiStatus: bmiStatus,
      );
    } else {
      _userData.updateData(newBmi: "n/a", newBmiStatus: "");
    }
  }

  // BMI Status Helper function (unchanged)
  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) {
      return "น้ำหนักน้อย";
    } else if (bmi >= 18.5 && bmi <= 22.9) {
      return "น้ำหนักปกติ";
    } else if (bmi >= 23 && bmi <= 24.9) {
      return "น้ำหนักเกิน";
    } else if (bmi >= 25 && bmi <= 29.9) {
      return "อ้วนระดับ 1";
    } else {
      return "อ้วนระดับ 2";
    }
  }

  // Weight/Height Input Dialog (unchanged)
  void _showWeightHeightInputDialog(BuildContext context) {
    _weightInputController.text = (_userData.weight == "n/a")
        ? ""
        : _userData.weight.replaceAll(" Kg", "");
    _heightInputController.text = (_userData.height == "n/a")
        ? ""
        : _userData.height.replaceAll(" cm", "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ใส่น้ำหนักและส่วนสูงของคุณ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _weightInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "น้ำหนัก (กิโลกรัม)",
                    hintText: "กรอกน้ำหนัก",
                    border: OutlineInputBorder(),
                    suffixText: 'กิโลกรัม',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _heightInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "ส่วนสูง (เซนติเมตร)",
                    hintText: "กรอกส่วนสูง",
                    border: OutlineInputBorder(),
                    suffixText: 'เซนติเมตร',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('บันทึก'),
              onPressed: () {
                _userData.updateData(
                  newWeight: _weightInputController.text.isNotEmpty
                      ? "${_weightInputController.text} Kg"
                      : "n/a",
                  newHeight: _heightInputController.text.isNotEmpty
                      ? "${_heightInputController.text} cm"
                      : "n/a",
                );
                _calculateAndSetBMI();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ข้อมูลถูกบันทึกแล้ว: น้ำหนัก ${_userData.weightNotifier.value}, ส่วนสูง ${_userData.heightNotifier.value}',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show Add Food Input Dialog
  void _showAddFoodInputDialog(BuildContext context) {
    // Reset controller values before opening dialog
    _menuNameController.clear();
    _riceAmountController.clear();
    _meatAmountController.clear(); // Clear new meat amount controller
    _selectedMeatType = null; // Reset selected meat type to null

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('เพิ่มรายการอาหาร'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _menuNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเมนู',
                    hintText: 'เช่น ข้าวผัดไก่',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMeatType,
                  decoration: const InputDecoration(
                    labelText:
                        'ประเภทโปรตีน (เลือกหรือไม่ก็ได้)', // Updated label
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('ไม่ระบุ'),
                    ), // Added 'ไม่ระบุ' option
                    DropdownMenuItem(
                      value: 'chicken_breast',
                      child: Text('อกไก่ (ไร้มัน)'),
                    ),
                    DropdownMenuItem(
                      value: 'chicken_thigh',
                      child: Text('สะโพกไก่ (มีมัน)'),
                    ),
                    DropdownMenuItem(
                      value: 'pork_lean',
                      child: Text('หมู (สันใน/เนื้อแดง)'),
                    ),
                    DropdownMenuItem(
                      value: 'pork_fatty',
                      child: Text('หมู (สามชั้น/ติดมัน)'),
                    ),
                    DropdownMenuItem(
                      value: 'beef_lean',
                      child: Text('เนื้อวัว (สันใน/เนื้อแดง)'),
                    ),
                    DropdownMenuItem(
                      value: 'beef_fatty',
                      child: Text('เนื้อวัว (ริบอาย/ติดมัน)'),
                    ),
                    DropdownMenuItem(
                      value: 'fish',
                      child: Text('เนื้อปลา (เช่น แซลมอน)'),
                    ),
                    DropdownMenuItem(
                      value: 'egg',
                      child: Text('ไข่ (โดยประมาณ 1 ฟอง ~50g)'),
                    ), // Updated egg description
                    DropdownMenuItem(
                      value: 'plant_protein',
                      child: Text('โปรตีนจากพืช'),
                    ),
                    DropdownMenuItem(
                      value: 'whey_protein',
                      child: Text('เวย์โปรตีน (Whey Protein)'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMeatType = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller:
                      _meatAmountController, // NEW: TextField for meat amount
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ปริมาณโปรตีน (กรัม)/ สกู๊ป (Scoop)',
                    hintText: 'เช่น 100 (ถ้าไม่มี ใส่ 0) หรือจำนวนสกู๊ป',
                    border: OutlineInputBorder(),
                    suffixText: 'กรัม / สกู๊ป',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _riceAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ปริมาณข้าว (กรัม)',
                    hintText: 'เช่น 100 (ถ้าไม่มีข้าว ใส่ 0)',
                    border: OutlineInputBorder(),
                    suffixText: 'กรัม',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('บันทึก'),
              onPressed: () {
                _addFoodItemAndCalculateMacros(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to add Food Item and calculate Macros
  void _addFoodItemAndCalculateMacros(BuildContext dialogContext) {
    final String menuName = _menuNameController.text.trim();
    final double riceAmount =
        double.tryParse(_riceAmountController.text) ?? 0.0;
    final double meatAmount =
        double.tryParse(_meatAmountController.text) ??
        0.0; // NEW: Get meat amount

    if (menuName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อเมนู')));
      return;
    }
    if (riceAmount < 0 || meatAmount < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ปริมาณต้องไม่ติดลบ')));
      return;
    }
    // Validate if at least one quantity is entered or protein type is selected
    if (riceAmount == 0 && meatAmount == 0 && _selectedMeatType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกปริมาณข้าวหรือโปรตีน หรือเลือกประเภทโปรตีน'),
        ),
      );
      return;
    }

    double protein = 0;
    double fat = 0;
    double carbohydrate = 0;
    double calories = 0;

    // Rice data (per 1 gram)
    // 100g Rice -> ~28g Carb, ~2.7g Protein, ~0.3g Fat, ~130 Kcal
    carbohydrate += (riceAmount / 100) * 28;
    protein += (riceAmount / 100) * 2.7;
    fat += (riceAmount / 100) * 0.3;
    calories += (riceAmount / 100) * 130;

    // Meat/Protein data (per 1 gram of meatAmount)
    // These values are approximate, you can adjust them for more accuracy.
    if (meatAmount > 0) {
      // Only calculate if meat amount is greater than 0
      switch (_selectedMeatType) {
        case 'chicken_breast': // Lean chicken breast (per 100g)
          protein += (meatAmount / 100) * 31;
          fat += (meatAmount / 100) * 3.6;
          calories += (meatAmount / 100) * 165;
          break;
        case 'chicken_thigh': // Chicken thigh (per 100g)
          protein += (meatAmount / 100) * 26;
          fat += (meatAmount / 100) * 10;
          calories += (meatAmount / 100) * 200;
          break;
        case 'pork_lean': // Lean pork (e.g., tenderloin, per 100g)
          protein += (meatAmount / 100) * 28;
          fat += (meatAmount / 100) * 5;
          calories += (meatAmount / 100) * 160;
          break;
        case 'pork_fatty': // Fatty pork (e.g., pork belly, per 100g)
          protein += (meatAmount / 100) * 14;
          fat += (meatAmount / 100) * 37;
          calories += (meatAmount / 100) * 390;
          break;
        case 'beef_lean': // Lean beef (e.g., sirloin, per 100g)
          protein += (meatAmount / 100) * 26;
          fat += (meatAmount / 100) * 15;
          calories += (meatAmount / 100) * 250;
          break;
        case 'beef_fatty': // Fatty beef (e.g., ribeye, per 100g)
          protein += (meatAmount / 100) * 20;
          fat += (meatAmount / 100) * 25;
          calories += (meatAmount / 100) * 310;
          break;
        case 'fish': // Fish (e.g., salmon, per 100g)
          protein += (meatAmount / 100) * 20;
          fat += (meatAmount / 100) * 13;
          calories += (meatAmount / 100) * 208;
          break;
        case 'egg': // Egg (assuming a large egg is ~50g, so per 100g for calculation)
          protein += (meatAmount / 100) * 13; // ~6g P per 50g egg
          fat += (meatAmount / 100) * 10; // ~5g F per 50g egg
          calories += (meatAmount / 100) * 155; // ~78 Kcal per 50g egg
          break;
        case 'plant_protein': // Generic plant-based protein (per 100g)
          protein += (meatAmount / 100) * 20;
          fat += (meatAmount / 100) * 5;
          calories += (meatAmount / 100) * 180;
          break;
        case 'whey_protein':
          // Now meatAmount directly represents the number of scoops
          protein += meatAmount * 25; // 25g protein per scoop
          fat += meatAmount * 2;     // 2g fat per scoop
          carbohydrate += meatAmount * 3; // 3g carb per scoop
          calories += meatAmount * 120; // 120 Kcal per scoop
          break;
        case null: // If 'ไม่ระบุ' is selected or no selection
        default:
          // No specific protein type selected, but meatAmount might be entered
          // You might want a default calculation for "other protein" if meatAmount > 0
          // For now, it will just add 0 if _selectedMeatType is null/default.
          break;
      }
    }

    // Create new FoodItem
    final newFood = FoodItem(
      name: menuName,
      meatType: _selectedMeatType,
      meatAmount: meatAmount, // Pass meatAmount to FoodItem
      riceAmount: riceAmount,
      protein: protein.roundToDouble(),
      fat: fat.roundToDouble(),
      carbohydrate: carbohydrate.roundToDouble(),
      calories: calories.roundToDouble(),
    );

    _userData.addFoodItem(newFood); // Add FoodItem to UserData

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('เพิ่มเมนู "${newFood.name}" แล้ว')));
    Navigator.of(dialogContext).pop(); // Close dialog
  }

  // Donut Chart Sections function (unchanged, but colors adjusted to match your original code)
  List<PieChartSectionData> _showingDonutSections(
    double protein,
    double fat,
    double carbohydrate,
  ) {
    final totalMacros = protein + fat + carbohydrate;
    if (totalMacros == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'ไม่มีข้อมูล',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    final proteinPercentage = (protein / totalMacros) * 100;
    final fatPercentage = (fat / totalMacros) * 100;
    final carbohydratePercentage = (carbohydrate / totalMacros) * 100;

    return [
      PieChartSectionData(
        color: const Color.fromARGB(255, 255, 183, 100), // Protein color
        value: protein,
        title: '${proteinPercentage.toStringAsFixed(0)}%',
        radius: _touchedDonutSectionIndex == 0 ? 120.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: _touchedDonutSectionIndex == 0 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      PieChartSectionData(
        color: const Color.fromARGB(255, 255, 86, 159), // Fat color
        value: fat,
        title: '${fatPercentage.toStringAsFixed(0)}%',
        radius: _touchedDonutSectionIndex == 1 ? 120.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: _touchedDonutSectionIndex == 1 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      PieChartSectionData(
        color: const Color.fromARGB(255, 114, 243, 234), // Carbohydrate color
        value: carbohydrate,
        title: '${carbohydratePercentage.toStringAsFixed(0)}%',
        radius: _touchedDonutSectionIndex == 2 ? 120.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: _touchedDonutSectionIndex == 2 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _weightInputController.dispose();
    _heightInputController.dispose();
    _menuNameController.dispose();
    _riceAmountController.dispose();
    _meatAmountController.dispose(); // NEW: Dispose meat amount controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KaoFit Health App',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 47, 217, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BMI Section (unchanged) ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _userData.weightNotifier,
                      builder: (context, currentWeight, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Weight',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentWeight,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _userData.heightNotifier,
                      builder: (context, currentHeight, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Height',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentHeight,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _userData.bmiNotifier,
                      builder: (context, currentBmi, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _userData.bmiStatusNotifier,
                          builder: (context, currentBmiStatus, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'BMI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentBmi,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (currentBmiStatus.isNotEmpty)
                                  Text(
                                    currentBmiStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: (currentBmiStatus == "น้ำหนักปกติ")
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showWeightHeightInputDialog(context);
                },
                child: Text(
                  'Edit BMI',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- Donut Chart Section ---
            const Divider(height: 30, thickness: 1),
            const Text(
              'Macro Nutrients Breakdown',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // The SizedBox height here seems very large. I've left it as is from your code,
            // but you might want to adjust it if it causes too much empty space.
            const SizedBox(height: 160),
            ValueListenableBuilder<double>(
              valueListenable: _userData.totalProteinNotifier,
              builder: (context, totalProtein, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: _userData.totalFatNotifier,
                  builder: (context, totalFat, child) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _userData.totalCarbohydrateNotifier,
                      builder: (context, totalCarbohydrate, child) {
                        return SizedBox(
                          height: 120,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          _touchedDonutSectionIndex = -1;
                                          return;
                                        }
                                        _touchedDonutSectionIndex =
                                            pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                      });
                                    },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              sections: _showingDonutSections(
                                totalProtein,
                                totalFat,
                                totalCarbohydrate,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            // The SizedBox height here also seems very large. Consider reducing it.
            const SizedBox(height: 150),
            // Legend for Donut Chart
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Indicator(
                    color: Color.fromARGB(255, 255, 183, 100),
                    text: 'Protein',
                    isSquare: true,
                  ),
                  Indicator(
                    color: Color.fromARGB(255, 255, 86, 159),
                    text: 'Fat',
                    isSquare: true,
                  ),
                  Indicator(
                    color: Color.fromARGB(255, 114, 243, 234),
                    text: 'Carbohydrate',
                    isSquare: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _showAddFoodInputDialog(context); // Button to add food
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Food Item',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 217, 255),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Display Total Calories
            ValueListenableBuilder<double>(
              valueListenable: _userData.totalCaloriesNotifier,
              builder: (context, totalCalories, child) {
                return Text(
                  'Total Calories: ${totalCalories.toStringAsFixed(0)} Kcal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 30),
            // Display Total Calories
            ValueListenableBuilder<double>(
            valueListenable: _userData.totalProteinNotifier, // Corrected
            builder: (context, totalProtein, child) { // Corrected
              return Text(
                'Total Proteins: ${totalProtein.toStringAsFixed(0)} g.', // Corrected
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 20),

            // --- List of Food Items (Updated to display protein type and amount) ---
            const Text(
              'Recorded Food Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<FoodItem>>(
              valueListenable: _userData.foodItemsNotifier,
              builder: (context, foodItems, child) {
                if (foodItems.isEmpty) {
                  return const Text(
                    'ยังไม่มีรายการอาหารที่บันทึกไว้',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    final item = foodItems[index];
                    String proteinDetail = '';
                    if (item.meatType != null &&
                        item.meatAmount != null &&
                        item.meatAmount! > 0) {
                      proteinDetail =
                          '${_getMeatTypeName(item.meatType!)}: ${item.meatAmount!.toStringAsFixed(0)}g | ';
                    } else if (item.meatType == null &&
                        item.meatAmount != null &&
                        item.meatAmount! > 0) {
                      proteinDetail =
                          'โปรตีนอื่นๆ: ${item.meatAmount!.toStringAsFixed(0)}g | ';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          // Updated subtitle to include protein detail
                          '${proteinDetail}ข้าว: ${item.riceAmount.toStringAsFixed(0)}g\n'
                          'P: ${item.protein.toStringAsFixed(1)}g | F: ${item.fat.toStringAsFixed(1)}g | C: ${item.carbohydrate.toStringAsFixed(1)}g | Kcal: ${item.calories.toStringAsFixed(0)}',
                        ),
                        isThreeLine:
                            true, // Allow for three lines if protein detail is long
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _userData.removeFoodItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ลบเมนู "${item.name}" แล้ว'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get readable meat type name
  String _getMeatTypeName(String key) {
    switch (key) {
      case 'chicken_breast':
        return 'อกไก่';
      case 'chicken_thigh':
        return 'สะโพกไก่';
      case 'pork_lean':
        return 'หมูเนื้อแดง';
      case 'pork_fatty':
        return 'หมูติดมัน';
      case 'beef_lean':
        return 'เนื้อวัวไม่ติดมัน';
      case 'beef_fatty':
        return 'เนื้อวัวติดมัน';
      case 'fish':
        return 'เนื้อปลา';
      case 'egg':
        return 'ไข่';
      case 'plant_protein':
        return 'โปรตีนจากพืช';
      default:
        return 'โปรตีนอื่นๆ';
    }
  }
}

// Widget for creating Indicator (unchanged)
class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
