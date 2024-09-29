import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Photo App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<String> items = [];
  String? selectedItem;
  final TextEditingController itemController = TextEditingController();

  void addItem() {
    setState(() {
      items.add(itemController.text);
      itemController.clear();
    });
  }

  void removeItem(String item) {
    setState(() {
      items.remove(item);
      if (selectedItem == item) {
        selectedItem = null; // Clear selection if the item is removed
      }
    });
  }

  Future<void> takePhoto() async {
    if (selectedItem == null) {
      return; // Return if no item is selected
    }

    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    String itemName = selectedItem!;
    final appDir = await getApplicationDocumentsDirectory();
    final itemDir = Directory('${appDir.path}/$itemName');

    if (!await itemDir.exists()) {
      await itemDir.create(recursive: true);
    }

    // Save the photo to the item folder with its original name
    final photoPath = '${itemDir.path}/${photo.name}';
    await File(photo.path).copy(photoPath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo saved: ${photo.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Photo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: takePhoto,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: itemController,
              decoration: InputDecoration(
                labelText: 'Add Item',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addItem,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeItem(item),
                  ),
                  onTap: () {
                    setState(() {
                      selectedItem = item; // Set the selected item
                    });
                  },
                  selected: selectedItem == item,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
