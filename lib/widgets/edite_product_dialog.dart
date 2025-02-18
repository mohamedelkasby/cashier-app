import 'package:cashier/services/database_helper.dart';
import 'package:flutter/material.dart';

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function() onUpdate;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _serialController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product['productName']);
    _serialController =
        TextEditingController(text: widget.product['serialNumber']);
    _priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _serialController,
            decoration: const InputDecoration(
              labelText: 'Serial Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
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
                DatabaseHelper.instance.updateProduct(
                  id: widget.product['id'],
                  productName: _nameController.text,
                  serialNumber: _serialController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                );
                widget.onUpdate();
                Navigator.pop(context);
              },
              child: const Text(
                'Update Product',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                DatabaseHelper.instance.deleteProduct(
                  id: widget.product['id'],
                );
                Navigator.pop(context);
                widget.onUpdate();
              },
              child: const Text(
                'Delete Product',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
