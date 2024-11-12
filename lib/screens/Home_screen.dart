import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (error) {
      print('Error fetching movies: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movies',
          style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 10,
        shadowColor: Colors.black45,
        actions: [
                Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                icon: Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
                },
                ),
                ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
          ),
        ),
      ),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index]['show'];
                return Card(
  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 6,
  shadowColor: Colors.black45,
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [Colors.blueAccent, Colors.deepPurpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(12),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: movie['image'] != null
            ? Image.network(
                movie['image']['medium'],
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              )
            : const Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.white54,
              ),
      ),
      title: Text(
        movie['name'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          movie['summary'] != null
              ? movie['summary'].replaceAll(RegExp(r'<[^>]*>'), '').substring(0, 80) + '...'
              : 'No summary available',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 18,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsScreen(movie: movie)),
        );
      },
    ),
  ),
                );

              },
            ),
    );
  }
}
