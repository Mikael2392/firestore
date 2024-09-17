import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HobbyListPage extends StatefulWidget {
  @override
  _HobbyListPageState createState() => _HobbyListPageState();
}

class _HobbyListPageState extends State<HobbyListPage> {
  // Firestore-Instanz initialisieren
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hobbies"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("Hobbies").snapshots(),
        builder: (context, snapshot) {
          final hobbies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: hobbies.length,
            itemBuilder: (context, index) {
              final hobbyData = hobbies[index].data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hobbyData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle:
                        Text("Bewertung: ${entry.value ?? 'Nicht bewertet'}"),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
