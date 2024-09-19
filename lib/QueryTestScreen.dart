import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueryTestScreen extends StatefulWidget {
  @override
  _QueryTestScreenState createState() => _QueryTestScreenState();
}

class _QueryTestScreenState extends State<QueryTestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedRating;
  String plz = '';

  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = false;

  Future<void> getFilteredRestaurants() async {
    setState(() {
      isLoading = true;
    });

    Query query = _firestore.collection('Restaurants');

    if (selectedRating != null && selectedRating!.isNotEmpty) {
      query = query.where('Rating', isEqualTo: int.parse(selectedRating!));
    }

    if (plz.isNotEmpty) {
      query = query.where('PLZ', isEqualTo: int.parse(plz));
    }

    try {
      QuerySnapshot querySnapshot = await query.get();

      setState(() {
        restaurants = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Restaurants"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedRating,
              decoration: const InputDecoration(
                labelText: 'Rating filtern',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('1 Stern')),
                DropdownMenuItem(value: '2', child: Text('2 Sterne')),
                DropdownMenuItem(value: '3', child: Text('3 Sterne')),
                DropdownMenuItem(value: '4', child: Text('4 Sterne')),
                DropdownMenuItem(value: '5', child: Text('5 Sterne')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRating = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'PLZ filtern',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  plz = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: getFilteredRestaurants,
            child: const Text('Restaurants abrufen'),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: restaurants.isEmpty
                      ? const Text("Keine Restaurants gefunden")
                      : ListView.builder(
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurantData = restaurants[index];
                            return ListTile(
                              title:
                                  Text(restaurantData['Name'] ?? 'Unbekannt'),
                              subtitle: Text(
                                  'PLZ: ${restaurantData['PLZ']}, Rating: ${restaurantData['Rating']}'),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
