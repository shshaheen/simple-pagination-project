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
      Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'),
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
        title: const Text(
          "Products",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight(400)),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: products.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < products.length) {
            final product = products[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product['thumbnail'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product['category'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "\$${product['price']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(product['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
