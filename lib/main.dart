import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const OdayPhoneApp());
}

class OdayPhoneApp extends StatelessWidget {
  const OdayPhoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oday Phone',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
  bool isAdmin = false;
  final ImagePicker _picker = ImagePicker();
  final settingsRef = FirebaseFirestore.instance.collection('settings').doc('banners');

  void checkAdmin() {
    final c = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('دخول الأدمن'),
      content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'oday123')),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(onPressed: (){
          if(c.text.trim()=='oday123'){ setState(()=> isAdmin=true); Navigator.pop(context); }
        }, child: const Text('دخول'))
      ],
    ));
  }

  Future<void> changeBanner(String type) async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if(img==null) return;
    final bytes = await img.readAsBytes();
    await settingsRef.set({type: base64Encode(bytes)}, SetOptions(merge: true));
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث $type للكل')));
  }

  void showMandoobDialog(String title) {
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(title),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقمك', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'العنوان - الإسماعيلية', border: OutlineInputBorder())),
      ]),
      actions: [ElevatedButton(onPressed: (){
          FirebaseFirestore.instance.collection('orders').add({'type': title, 'phone': phoneCtrl.text, 'address': addressCtrl.text, 'time': FieldValue.serverTimestamp()});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الارسال - المندوب هيكلمك')));
        }, child: const Text('اطلب الان'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oday Phone'), actions: [IconButton(icon: Icon(isAdmin?Icons.lock_open:Icons.lock), onPressed: checkAdmin)]),
      body: StreamBuilder<DocumentSnapshot>(
        stream: settingsRef.snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String,dynamic>?;
          Uint8List? topBytes, bottomBytes;
          if(data?['topImage']!=null){ try{ topBytes=base64Decode(data!['topImage']); }catch(_){} }
          if(data?['bottomImage']!=null){ try{ bottomBytes=base64Decode(data!['bottomImage']); }catch(_){} }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1- البانر فوق - صورتك WA9506
                Stack(children: [
                  Container(
                    height: 220, width: double.infinity,
                    child: topBytes!=null 
                      ? Image.memory(topBytes, fit: BoxFit.cover) 
                      : Image.asset('IMG-20261031-WA9506.jpg', fit: BoxFit.cover),
                  ),
                  if(isAdmin) Positioned(right: 8, top: 8, child: ElevatedButton(onPressed: ()=> changeBanner('topImage'), child: const Text('غير صورة فوق'))),
                ]),

                const SizedBox(height: 12),

                // اهم زرار
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: double.infinity, height: 70,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                      icon: const Icon(Icons.shopping_bag, size: 30),
                      label: const Text('🛒 متجر الإكسسوارات بالصور', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const StorePage())),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    Expanded(child: InkWell(onTap: ()=> showMandoobDialog('طلب مندوب'), child: Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(15), child: Column(children: const [Icon(Icons.delivery_dining, size: 35, color: Colors.orange), SizedBox(height: 5), Text('اطلب مندوب', style: TextStyle(fontWeight: FontWeight.bold))]))))),
                    const SizedBox(width: 10),
                    Expanded(child: InkWell(onTap: ()=> showMandoobDialog('صيانة موبايلك من المنزل'), child: Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(15), child: Column(children: const [Icon(Icons.build, size: 35, color: Colors.green), SizedBox(height: 5), Text('صيانة من المنزل', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))]))))),
                  ]),
                ),

                const SizedBox(height: 12),

                // 2- الصورة تحت - صورتك WA4508 بتملى الفراغ الابيض
                Stack(children: [
                  Container(
                    height: 300, width: double.infinity,
                    child: bottomBytes!=null 
                      ? Image.memory(bottomBytes, fit: BoxFit.cover) 
                      : Image.asset('IMG-20261031-WA4508.jpg', fit: BoxFit.cover),
                  ),
                  if(isAdmin) Positioned(right: 8, top: 8, child: ElevatedButton(onPressed: ()=> changeBanner('bottomImage'), child: const Text('غير صورة تحت'))),
                ]),

                Container(width: double.infinity, color: Colors.black, padding: const EdgeInsets.all(12), child: const Text('📍 الإسماعيلية - توصيل لحد البيت | كل خدمات المحمول - Oday Phone', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final productsRef = FirebaseFirestore.instance.collection('products');
  final ImagePicker _picker = ImagePicker();

  Future<void> addProduct() async {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    Uint8List? imageBytes;
    String? base64Image;
    await showDialog(context: context, builder: (context){
      return StatefulBuilder(builder: (context, setD){
        return AlertDialog(
          title: const Text('إضافة منتج بصورة'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () async {
                final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                if(img!=null){ final b = await img.readAsBytes(); setD((){ imageBytes=b; base64Image=base64Encode(b); }); }
              },
              child: Container(height: 140, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
                child: imageBytes!=null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(imageBytes!, fit: BoxFit.cover, width: double.infinity)) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40), Text('دوس لاختيار صورة المنتج')])),
            ),
            const SizedBox(height: 10),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder())),
          ])),
          actions: [
            TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () async {
              if(nameC.text.isEmpty || base64Image==null) return;
              Navigator.pop(context);
              await productsRef.add({'name': nameC.text.trim(), 'price': priceC.text.trim(), 'imageBase64': base64Image, 'createdAt': FieldValue.serverTimestamp()});
            }, child: const Text('حفظ بالصورة'))
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('متجر الإكسسوارات'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: addProduct)]),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if(!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if(docs.isEmpty) return const Center(child: Text('مفيش منتجات لسه - دوس + وضيف'));
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: docs.length,
            itemBuilder: (_, i){
              final data = docs[i].data() as Map<String,dynamic>;
              final String? img64 = data['imageBase64'];
              Uint8List? imgBytes;
              if(img64!=null){ try{ imgBytes=base64Decode(img64);}catch(_){} }
              return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: imgBytes!=null ? Image.memory(imgBytes, fit: BoxFit.cover, width: double.infinity) : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)))),
                Padding(padding: const EdgeInsets.all(8), child: Column(children: [
                  Text(data['name']??'', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${data['price']??''} جنيه', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ])),
              ]));
            },
          );
        },
      ),
    );
  }
}
