import 'package:flutter/material.dart';
import 'package:place_search_and_map/ui/screens/home_screen/home_screen.dart';

//https://medium.com/comerge/location-search-autocomplete-in-flutter-84f155d44721
//https://www.youtube.com/watch?v=sL74UNLssV8
//https://stackoverflow.com/questions/55870508/how-to-create-a-simple-google-maps-address-search-with-autocomplete-in-flutter-a/55877236

//https://developers.google.com/maps/documentation
//https://developers.google.com/maps/documentation/places/web-service/overview

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Search and Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(title: 'Place Search and Map Demo'),
    );
  }
}


