import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List searchResults = [];
  List suggestionList = [];
  bool isLoading = false;
  Timer? _debounce;

  // Debounced Search Function for Suggestions
  void searchMovies(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isNotEmpty) {
        setState(() {
          isLoading = true;
          suggestionList = [];
        });
        try {
          final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              suggestionList = data.isNotEmpty ? data : [];
            });
          }
        } catch (error) {
          setState(() {
            suggestionList = [];
          });
        } finally {
          setState(() => isLoading = false);
        }
      }
    });
  }

  // Finalized Search for Results
  void getMovieResults(String query) async {
    setState(() {
      isLoading = true;
      searchResults = [];
    });
    try {
      final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data.isNotEmpty ? data : [];
        });
      }
    } catch (error) {
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurpleAccent,
        title: Row(
          children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
          hintText: 'Search movies...',
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurpleAccent),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            onChanged: searchMovies,
            onSubmitted: getMovieResults,
          ),
        ),
        if (searchResults.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
          setState(() {
            searchResults = [];
            suggestionList = [];
          });
            },
          ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
        itemCount: searchResults.isNotEmpty ? searchResults.length : suggestionList.length,
        itemBuilder: (context, index) {
          final movie = searchResults.isNotEmpty ? searchResults[index]['show'] : suggestionList[index]['show'];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
            ),
            elevation: 6,
            shadowColor: Colors.black45,
            child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
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
              style: const TextStyle(
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
              ),
            ),
            trailing: const Icon(
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
          if (isLoading)
        const Center(
          child: CircularProgressIndicator(),
        ),
        ],
      ),
    );
  }
}
