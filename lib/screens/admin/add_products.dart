import 'package:cashier/services/database_helper.dart';
import 'package:cashier/widgets/edite_product_dialog.dart';
import 'package:flutter/material.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  List<Map<String, dynamic>> products = [];
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productSerialNumberController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool showSearch = false;

  Future<List<Map<String, dynamic>>> get allProducts async {
    final db = await DatabaseHelper.instance.database;
    return db.query('products');
  }

  Future<void> loadProducts() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> fetchedProducts =
        await db.query('products');
    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productSerialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: productPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        DatabaseHelper.instance.addProduct(
                          productName: productNameController.text,
                          serialNumber: productSerialNumberController.text,
                          price: double.tryParse(productPriceController.text) ??
                              0.0,
                        );
                        productNameController.clear();
                        productSerialNumberController.clear();
                        productPriceController.clear();
                        loadProducts();
                      },
                      child: const Text('Add Product'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Search Products'),
                    controller: searchController,
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        loadProducts();
                        setState(() {
                          showSearch = false;
                        });
                        return;
                      }
                      try {
                        final List<Map<String, dynamic>> allAvailableProducts =
                            await allProducts;
                        final List<Map<String, dynamic>> filteredProducts =
                            allAvailableProducts.where((product) {
                          return product['id'].toString().contains(value) ||
                              product['productName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase());
                        }).toList();
                        setState(() {
                          products = filteredProducts;
                          showSearch = true;
                        });
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (showSearch)
                    Row(
                      children: [
                        Text(
                          'Search Results: ${products.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            searchController.clear();
                            loadProducts();
                            setState(() {
                              showSearch = false;
                            });
                          },
                          child: const Text('Clear Search'),
                        )
                      ],
                    ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Text(
                                "${products[index]['id']}",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              title: Text(
                                products[index]['productName'],
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(products[index]['serialNumber']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${products[index]['price']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    hoverColor: Colors.transparent,
                                    icon: const Icon(
                                      Icons.edit_document,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => EditProductDialog(
                                          product: products[index],
                                          onUpdate: () {
                                            loadProducts();
                                          },
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              dense: true,
                            ),
                            const Divider()
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
