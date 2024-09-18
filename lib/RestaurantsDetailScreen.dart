import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({required this.restaurantId});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _plzController = TextEditingController();
  final _ratingController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  void _loadRestaurantData() async {
    try {
      final doc = await _firestore
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['Name'] ?? '';
        _plzController.text = data['PLZ'].toString();
        _ratingController.text = data['Rating'].toString();
      }
    } catch (e) {
      print("Error loading restaurant: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveRestaurant() async {
    try {
      await _firestore
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .update({
        'Name': _nameController.text,
        'PLZ': int.parse(_plzController.text),
        'Rating': int.parse(_ratingController.text),
      });
      Navigator.of(context).pop();
    } catch (e) {
      print("Error updating restaurant: $e");
    }
  }

  void _deleteRestaurant() async {
    try {
      await _firestore
          .collection('Restaurants')
          .doc(widget.restaurantId)
          .delete();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error deleting restaurant: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteRestaurant();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _plzController,
              decoration: const InputDecoration(labelText: 'PLZ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Rating'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRestaurant,
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
