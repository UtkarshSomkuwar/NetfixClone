import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Add this utility function at the top of the file
String removeHtmlTags(String htmlText) {
  final RegExp htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(htmlTagRegExp, '');
}

class DetailsScreen extends StatefulWidget {
  final dynamic movie; // Receive movie data from HomeScreen or SearchScreen

  DetailsScreen({required this.movie});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  dynamic movieDetails;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/shows/${widget.movie['id']}'));

    if (response.statusCode == 200) {
      setState(() {
        movieDetails = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movieDetails == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Movie Details', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Movie Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centering and reducing the size of the thumbnail
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    movieDetails['image'] != null
                        ? movieDetails['image']['original']
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    width: 250, // Reduced size of the thumbnail image
                    height: 375, // Adjusted height for a smaller image
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Movie Name
              Text(
                movieDetails['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Genres
              Text(
                'Genres: ${movieDetails['genres'].join(', ')}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              // Rating
              Text(
                'Rating: ${movieDetails['rating']['average'] ?? 'N/A'}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              // Premiered Date
              Text(
                'Premiered: ${movieDetails['premiered'] ?? 'N/A'}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              // Network
              Text(
                'Network: ${movieDetails['network'] != null ? movieDetails['network']['name'] : 'N/A'}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              // Movie Summary
              Text(
                movieDetails['summary'] != null
                    ? removeHtmlTags(movieDetails['summary']) // Remove HTML tags here
                    : 'No summary available',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              // Cast Section (Optional)
              if (movieDetails['cast'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cast:',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...movieDetails['cast'].map<Widget>((castMember) {
                      return Text(
                        castMember['person']['name'] ?? 'Unknown',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
