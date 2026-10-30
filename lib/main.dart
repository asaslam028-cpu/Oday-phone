import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const OdayApp());

class OdayApp extends StatelessWidget {
  const OdayApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oday Phone',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  bool isOwnerMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final prod = prefs.getString('oday_products');
    final ord = prefs.getString('oday_orders');
    if (prod != null) products = List<Map<String, dynamic>>.from(jsonDecode(prod));
    if (ord != null) orders = List<Map<String, dynamic>>.from(jsonDecode(ord));
    setState(() {});
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('oday_products', jsonEncode(products));
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('oday_orders', jsonEncode(orders));
  }

  void _showMandoobSheet() {
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final problemCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String problemType = 'صيانة سوفت وير';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 16),
                const Text('اطلب مندوب صيانة من المنزل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                const Text('داخل الإسماعيلية فقط - 01069068091', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: problemType,
                  decoration: const InputDecoration(labelText: 'نوع العطل / المشكلة', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'صيانة سوفت وير', child: Text('صيانة سوفت وير')),
                    DropdownMenuItem(value: 'صيانة هارد وير', child: Text('صيانة هارد وير')),
                    DropdownMenuItem(value: 'تغيير شاشة', child: Text('تغيير شاشة')),
                    DropdownMenuItem(value: 'تغيير بطارية', child: Text('تغيير بطارية')),
                    DropdownMenuItem(value: 'مشكلة شحن', child: Text('مشكلة شحن')),
                    DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                  ],
                  onChanged: (v) => setModal(() => problemType = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: problemCtrl, decoration: const InputDecoration(labelText: 'موديل الجهاز', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'وصف المشكلة بالتفصيل', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم تليفونك', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone))),
                const SizedBox(height: 12),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'العنوان داخل الإسماعيلية', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (phoneCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('من فضلك اكتب رقمك وعنوانك')));
                      return;
                    }
                    final order = {'type': problemType, 'model': problemCtrl.text, 'desc': descCtrl.text, 'phone': phoneCtrl.text, 'address': addressCtrl.text, 'date': DateTime.now().toString()};
                    setState(() => orders.add(order));
                    _saveOrders();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك! سيتم التواصل معك على 01069068091'), backgroundColor: Colors.green));
                  },
                  child: const Text('اطلب مندوب حالاً - 01069068091', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
          const SizedBox(height: 8),
          TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر بالجنيه')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'تفاصيل')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () { if (nameCtrl.text.trim().isEmpty) return; setState(() => products.insert(0, {'name': nameCtrl.text.trim(), 'price': priceCtrl.text.trim(), 'desc': descCtrl.text.trim()})); _saveProducts(); Navigator.pop(context); }, child: const Text('حفظ'))
        ],
      ),
    );
  }

  void _openShop() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ShopPage(products: products, isOwner: isOwnerMode, onDelete: (i) { setState(() => products.removeAt(i)); _saveProducts(); })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, title: const Text('Oday Phone - عدي فون', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, actions: [IconButton(icon: Icon(isOwnerMode ? Icons.store : Icons.admin_panel_settings), onPressed: () { setState(() => isOwnerMode = !isOwnerMode); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isOwnerMode ? 'وضع المالك: تقدر تضيف منتجات' : 'وضع العميل'))); })]),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)), child: const Icon(Icons.phone_iphone, size: 50, color: Color(0xFF0D47A1))), const SizedBox(height: 12), const Text('عدي فون', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), child: const Text('خدمات داخل الإسماعيلية فقط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(height: 8), const Text('01069068091 - صيانة واكسسوارات', style: TextStyle(color: Colors.white70))])),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: const [Icon(Icons.home_repair_service, color: Color(0xFF0D47A1), size: 28), SizedBox(width: 8), Text('خدمة صيانة من المنزل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), const Text('مندوب يجيلك لحد البيت يستلم الجهاز ويرجعه بعد الصيانة', style: TextStyle(color: Colors.black54)), const SizedBox(height: 12), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _showMandoobSheet, icon: const Icon(Icons.delivery_dining, color: Colors.white), label: const Text('اطلب مندوب حالاً', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))]))),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: _buildBigButton(icon: Icons.shopping_bag, title: 'تسوق اكسسوارات', subtitle: '${products.length} منتج', color: const Color(0xFF0D47A1), onTap: _openShop)), const SizedBox(width: 12), Expanded(child: _buildBigButton(icon: Icons.receipt_long, title: 'طلباتي', subtitle: '${orders.length} طلب', color: Colors.green.shade700, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersPage(orders: orders))); }))]))
        ]),
      ),
      floatingActionButton: isOwnerMode ? FloatingActionButton.extended(onPressed: _addProductDialog, icon: const Icon(Icons.add), label: const Text('إضافة منتج')) : FloatingActionButton.extended(onPressed: _showMandoobSheet, backgroundColor: Colors.red, icon: const Icon(Icons.delivery_dining, color: Colors.white), label: const Text('اطلب مندوب', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildBigButton({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 30)), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12))])))
  }
}

class ShopPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final bool isOwner;
  final Function(int) onDelete;
  const ShopPage({super.key, required this.products, required this.isOwner, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('متجر اكسسوارات عدي فون'), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white), body: products.isEmpty ? const Center(child: Text('المتجر فاضي حالياً\nسيتم إضافة المنتجات قريباً', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))) : GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8), itemCount: products.length, itemBuilder: (_, i) { final p = products[i]; return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Stack(children: [Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.phone_android, size: 50, color: Color(0xFF0D47A1)), const SizedBox(height: 10), Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 4), Text('${p['price']} جنيه', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), if (p['desc'].toString().isNotEmpty) Text(p['desc'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center)])), if (isOwner) Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { onDelete(i); Navigator.pop(context); }))])) ; }));
  }
}

class OrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const OrdersPage({super.key, required this.orders});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('طلبات المندوب'), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white), body: orders.isEmpty ? const Center(child: Text('لا يوجد طلبات بعد')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: orders.length, itemBuilder: (_, i) { final o = orders[i]; return Card(child: ListTile(leading: const Icon(Icons.delivery_dining, color: Colors.red), title: Text(o['type']), subtitle: Text('📞 ${o['phone']} - 📍 ${o['address']}\n${o['desc']}'), isThreeLine: true)); }));
  }
}
