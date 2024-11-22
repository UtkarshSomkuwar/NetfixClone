import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'details_screen.dart'; // Import DetailsScreen

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> searchResults = [];
  List<dynamic> suggestions = []; // List to hold suggestions

  @override
  void initState() {
    super.initState();
    // Load 10 movie suggestions when the search page loads
    loadSuggestions();
  }

  // Fetch movie suggestions (popular or generic list)
  Future<void> loadSuggestions() async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        suggestions = data.take(10).toList(); // Show top 10 movies as suggestions
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  // Fetch movie results based on the search term
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        searchResults = data;
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  // Navigate to the DetailsScreen when a movie card is clicked
  void _navigateToDetailsPage(dynamic movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movie), // Pass movie data to DetailsScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Movies', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        // Set the back arrow icon color to white
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black, // Set background to black
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a movie...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800], // Grey color for contrast
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                searchMovies(query);
              },
            ),
            SizedBox(height: 20),
            searchResults.isEmpty && _controller.text.isNotEmpty
                ? Center(child: Text('No results found', style: TextStyle(color: Colors.white)))
                : Expanded(
              child: searchResults.isEmpty && _controller.text.isEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Movies',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        var movie = suggestions[index]['show'];
                        return GestureDetector(
                          onTap: () => _navigateToDetailsPage(movie), // On movie click, navigate to DetailsScreen
                          child: MovieCard(
                            title: movie['name'],
                            imageUrl: movie['image'] != null ? movie['image']['medium'] : 'https://via.placeholder.com/150',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var movie = searchResults[index]['show'];
                  return GestureDetector(
                    onTap: () => _navigateToDetailsPage(movie), // On movie click, navigate to DetailsScreen
                    child: MovieCard(
                      title: movie['name'],
                      imageUrl: movie['image'] != null ? movie['image']['medium'] : 'https://via.placeholder.com/150',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  MovieCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Reduced height for smaller card
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 60,
              width: 60, // Smaller image size
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis, // Truncate long titles
            ),
          ),
        ],
      ),
    );
  }
}