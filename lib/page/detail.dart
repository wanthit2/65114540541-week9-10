import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late int counter;

  @override
  void initState() {
    super.initState();
    // รับค่าจาก Get.arguments (ส่งมาจากหน้าแรก)
    counter = Get.arguments ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ค่าจากหน้าแรก: $counter', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Hero(
              tag: 'logoHero',
              child: Image(
                image: AssetImage('images/logo.jpg'),
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
