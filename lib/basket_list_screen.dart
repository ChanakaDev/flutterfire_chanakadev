// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '/item.dart';

// Create uuid object
var uuid = Uuid();

class BasketListScreen extends StatefulWidget {
  const BasketListScreen({super.key});

  @override
  State<BasketListScreen> createState() => _BasketListScreenState();
}

class _BasketListScreenState extends State<BasketListScreen> {
  // List to temporarily hold fetched and mapped data
  List<Item> basketItems = [];

  @override
  void initState() {
    // Call super.initState method
    super.initState();

    // Call fetchRecords method
    fetchRecords();

    // Event to listen for the realtime updates
    FirebaseFirestore.instance
        .collection('basket_items')
        .snapshots()
        .listen((event) {
      mapRecords(event);
    });
  }

  // Method to fetch data from firebase
  fetchRecords() async {
    // Get request (same as "SELECT * FROM Table_Name" in SQL)
    var records =
        await FirebaseFirestore.instance.collection('basket_items').get();
    // Call mapRecords method
    mapRecords(records);
  }

  // Method to map fetched data to a list of models
  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    // Codes written for the debug purpose
    print("length${records.docs.length}");
    for (int i = 0; records.docs.length > i; i++) {
      print(records.docs[i].data());
    }

    // Map data and convert to a list using .toList() method
    var list = records.docs
        .map(
          (item) => Item(
            id: item['id'],
            product: item['product'],
            quantity: item['quantity'],
          ),
        )
        .toList();

    // Update the UI as the values of the local list updates
    setState(() {
      basketItems = list;
    });
  }

  // Method to show a dialog box
  showAddDataDialog() {
    // Conterllers for text feilds
    var productController = TextEditingController();
    var quantityController = TextEditingController();

    // Flutter's default Dialog (showDialog method)
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // Content of the dialog
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Product name',
                  ),
                  controller: productController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                  controller: quantityController,
                ),
                TextButton(
                  onPressed: () {
                    // trim method removes the unwanted white spaces
                    var product = productController.text.trim();
                    var quantity = quantityController.text.trim();
                    // Call the method to add data to the firebase
                    addItem(product, quantity);
                    // Close dialog after adding data
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  addItem(String product, String quantity) {
    // Create an Item object to, add to the firestore database
    var item =
        Item(id: uuid.v1().toString(), product: product, quantity: quantity);
    // Add method required a map (you can see it by hover overing it),
    // that means it requires a JSON file;
    // For that we are using the toJson method of the item model;
    // Because item object has created from the Item class;
    // So, we can use it's methods through that object.
    FirebaseFirestore.instance.collection('basket_items').add(item.toJson());
  }

  deleteItem(String id) {
    // Quory to delete data from firebase
    FirebaseFirestore.instance.collection('basket_items').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Basket Screen",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Call the method to show the dialog box
              showAddDataDialog();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        // Usually we give length of the list here
        itemCount: basketItems.length,

        // Building the list items
        itemBuilder: (context, index) {
          // View of a one item
          return ListTile(
            title: Text('product: ${basketItems[index].product}'),
            subtitle: Text('Quantity: ${basketItems[index].quantity}'),
            trailing: IconButton(
              onPressed: () {
                print("Delete item number: $index");
                print("Index ${basketItems[index].id}");
                // Call the delete method
                deleteItem(basketItems[index].id);
              },
              icon: const Icon(
                Icons.delete,
              ),
            ),
          );
        },
      ),
    );
  }
}
