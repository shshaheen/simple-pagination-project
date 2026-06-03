import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaginationScreen extends StatefulWidget {
  const PaginationScreen({super.key});

  @override
  State<PaginationScreen> createState() => _PaginationScreenState();
}

class _PaginationScreenState extends State<PaginationScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> products = [];

  int page = 1;
  final int limit = 20;

  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();

    fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchProducts();
      }
    });
  }

  Future<void> fetchProducts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final skip = (page - 1) * limit;

    final response = await http.get(
      Uri.parse(
        'https://dummyjson.com/products?limit=$limit&skip=$skip',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<dynamic> newProducts = data['products'];

      setState(() {
        products.addAll(newProducts);

        page++;

        if (newProducts.length < limit) {
          hasMore = false;
        }

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: products.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < products.length) {
            final product = products[index];

            return ListTile(
              leading: Image.network(
                product['thumbnail'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product['title']),
              subtitle: Text(
                "\$${product['price']}",
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}