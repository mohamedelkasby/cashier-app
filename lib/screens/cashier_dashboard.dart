import 'package:cashier/screens/login_screen.dart';
import 'package:cashier/services/database_helper.dart';
import 'package:flutter/material.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> products = [];
  double total = 0.0;
  TextEditingController searchController = TextEditingController();

  Future<List<Map<String, dynamic>>> get allProducts async {
    final db = await DatabaseHelper.instance.database;
    return db.query('products');
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
      total += product['price'];
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
      total = 0;
    });
  }

  Future<void> processSale() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sale Complete'),
        content: Text('Total Amount: \$${total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () {
              clearCart();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    allProducts.then((value) => setState(() {
          products = value;
        }));
  }

  void searchProduct(String value) async {
    final search = value.toLowerCase();
    final List<Map<String, dynamic>> searchAllProducts = await allProducts;
    setState(() {
      products = search.isEmpty
          ? searchAllProducts
          : searchAllProducts.where((product) {
              return product['id'].toString().contains(search) ||
                  product['productName']
                      .toString()
                      .toLowerCase()
                      .contains(search);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 2, child: buildProductGrid()),
          buildCart(),
        ],
      ),
    );
  }

  Widget buildProductGrid() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: searchProduct,
            decoration: const InputDecoration(
              labelText: 'Search Products',
              prefixIcon: Icon(Icons.search),
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: InkWell(
                  onTap: () => addToCart(product),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(product['productName'],
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('\$${product['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCart() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          buildCartHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  dense: true,
                  title: Text(item['productName']),
                  trailing: Text('\$${item['price'].toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          buildCartFooter(),
        ],
      ),
    );
  }

  Widget buildCartHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("name",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(width: 8),
          Text("count",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(width: 8),
          Text("price",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget buildCartFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: clearCart,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: processSale,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child:
                      const Text('Pay', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
