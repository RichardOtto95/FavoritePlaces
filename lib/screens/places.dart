import 'package:favorite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';

class PLacesScreen extends StatelessWidget {
  const PLacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PlacesList(
        places: const [],
      ),
    );
  }
}
