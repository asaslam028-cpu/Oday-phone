import 'package:flutter/material.dart';

void main() {
  runApp(const OdayApp());
}

class OdayApp extends StatelessWidget {
  const OdayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oday Phone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String phoneNumber = "01069068091";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Column(
          children: [
            Text("Oday Phone", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("داخل الإسماعيلية فقط", style: TextStyle(fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.phone_android, size: 60, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text("Oday Phone", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(phoneNumber, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(20)),
                    child: const Text("داخل الإسماعيلية فقط", style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildServiceCard("صيانة موبايلات", Icons.build, Colors.orange),
            buildServiceCard("بيع اكسسوارات", Icons.headset, Colors.purple),
            buildServiceCard("شحن رصيد - فودافون كاش", Icons.account_balance_wallet, Colors.green),
            buildServiceCard("خدمات سوفت وير", Icons.memory, Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text("اتصل الآن - $phoneNumber", style: const TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Beni Ibeid, Dakahlia - نخدم الإسماعيلية فقط", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
