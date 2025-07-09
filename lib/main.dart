import 'package:flutter/material.dart';
import 'package:my_app/home.dart'; // ตรวจสอบ path นี้ให้ถูกต้อง
import 'package:my_app/signup_page.dart'; // ตรวจสอบ path นี้ให้ถูกต้อง
import 'package:shared_preferences/shared_preferences.dart'; // <<< เพิ่มบรรทัดนี้

// ไม่จำเป็นต้อง import 'package:firebase_core/firebase_core.dart';
// ไม่จำเป็นต้อง import 'package:my_app/firebase_options.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaoFit Health App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromARGB(255, 47, 217, 255),
      ),
      home: const MainPage(),
    ),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _usernameController = TextEditingController(); // <<< เปลี่ยนกลับเป็น username
  final TextEditingController _passwordController = TextEditingController();

  // ไม่จำเป็นต้องใช้ FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async { // <<< ต้องมี async
    final String enteredUsername = _usernameController.text;
    final String enteredPassword = _passwordController.text;

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username and password.')),
      );
      return;
    }

    // <<< Logic การ Login ด้วย shared_preferences
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (enteredUsername == savedUsername && enteredPassword == savedPassword) {
      // Login สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
      // นำทางไปยัง HomePage
      Navigator.pushReplacement( // ใช้ pushReplacement เพื่อไม่ให้กลับมาหน้า Login ได้
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Login ไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Username or Password')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose(); // <<< เปลี่ยนเป็น usernameController
    _passwordController.dispose();
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Let\'s get fit together!',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _usernameController, // <<< ผูกกับ _usernameController
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your username', // <<< เปลี่ยนเป็น Username
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your password',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 47, 217, 255),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}