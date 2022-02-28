import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Get request
Future<List<Photo>> fetchPhotos() async {
  String url = 'https://jsonplaceholder.typicode.com/photos';
  final response = await http.get(Uri.parse(url));

// Runs parsePhotos in a seperate isolate
  return compute(parsePhotos, response.body);
}

// Converts a response body into a List>Photo>
List<Photo> parsePhotos(String responseBody) {
  // Parses the string and converts the JSON object into a map
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  // Returns the parsed map and returns a photo list
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

// A model class for the JSON object

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  const Photo(
      {required this.albumId,
      required this.id,
      required this.title,
      required this.url,
      required this.thumbnailUrl});

  //  A factory constructor for creating a new Photo instanace from a JSON map structure
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

// Root of the widget tree
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Json Photo List';

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: appTitle,
      ),
    );
  }
}

// MyHomePage Widget

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occured'),
            );
          } else if (snapshot.hasData) {
            return PhotosList(photos: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// PhotoList Widget
class PhotosList extends StatelessWidget {
  const PhotosList({Key? key, required this.photos}) : super(key: key);
  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Image.network(photos[index].thumbnailUrl);
        });
  }
}
