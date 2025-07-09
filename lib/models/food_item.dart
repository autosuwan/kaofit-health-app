class FoodItem {
  final String name;
  final String? meatType;
  final double? meatAmount;
  final double riceAmount;
  final double protein;
  final double fat;
  final double carbohydrate;
  final double calories;

  FoodItem({
    required this.name,
    this.meatType,
    this.meatAmount,
    required this.riceAmount,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.calories,
  });

  // เมธอดสำหรับแปลง FoodItem เป็น Map (สำหรับ JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'meatType': meatType,
      'meatAmount': meatAmount, // ค่า Nullable จะถูกเก็บเป็น null ใน JSON
      'riceAmount': riceAmount,
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
      'calories': calories,
    };
  }

  // Factory constructor สำหรับสร้าง FoodItem จาก Map (จาก JSON)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      meatType: json['meatType'] as String?, // ดึงค่า String หรือ null
      meatAmount: (json['meatAmount'] as num?)?.toDouble(), // ดึงค่า num (int หรือ double) แล้วแปลงเป็น double?
      riceAmount: (json['riceAmount'] as num).toDouble(), // ดึงค่า num แล้วแปลงเป็น double
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
    );
  }
}