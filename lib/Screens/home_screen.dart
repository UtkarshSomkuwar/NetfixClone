import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'details_screen.dart'; // Import the DetailsScreen
import 'search_screen.dart'; // Import the SearchScreen

String removeHtmlTags(String htmlText) {
  final RegExp htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(htmlTagRegExp, '');
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> popularMovies;
  late Future<List<dynamic>> animeMovies;
  late Future<List<dynamic>> actionMovies;
  late Future<List<dynamic>> comedyMovies;
  late Future<List<dynamic>> horrorMovies;
  late Future<List<dynamic>> thrillerMovies;
  late Future<List<dynamic>> romanticMovies;

  dynamic featuredMovie; // To hold the randomly chosen popular movie
  bool isLoading = true; // Flag to track if data is loading
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    setState(() {
      isLoading = true;
    });

    popularMovies = fetchMoviesByCategory('popular');
    animeMovies = fetchMoviesByCategory('anime');
    actionMovies = fetchMoviesByCategory('action');
    comedyMovies = fetchMoviesByCategory('comedy');
    horrorMovies = fetchMoviesByCategory('horror');
    thrillerMovies = fetchMoviesByCategory('thriller');
    romanticMovies = fetchMoviesByCategory('romance');

    // Wait for all movie categories to finish loading
    await Future.wait([
      popularMovies,
      animeMovies,
      actionMovies,
      comedyMovies,
      horrorMovies,
      thrillerMovies,
      romanticMovies,
    ]);

    // Choose a random popular movie for the featured section
    final movies = await popularMovies;
    setState(() {
      isLoading = false;
      if (movies.isNotEmpty) {
        featuredMovie = movies[0]['show']; // You can randomize this selection if desired
      }
    });
  }

  Future<List<dynamic>> fetchMoviesByCategory(String category) async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$category'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Filter movies to exclude ones without thumbnails
      return data.where((movie) => movie['show']['image'] != null).toList();
    } else {
      throw Exception('Failed to load $category movies');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  void _navigateToDetailsPage(dynamic movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/SXlogo.png', // Path to your image
              height: 30, // Adjust the height of the image
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Single central loader
          : ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          if (featuredMovie != null) buildFeaturedMovie(featuredMovie), // Add the featured movie widget
          buildMovieSection('Anime', animeMovies),
          buildMovieSection('Action', actionMovies),
          buildMovieSection('Comedy', comedyMovies),
          buildMovieSection('Horror', horrorMovies),
          buildMovieSection('Thrillers', thrillerMovies),
          buildMovieSection('Romantic', romanticMovies),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildFeaturedMovie(dynamic movie) {
    return GestureDetector(
      onTap: () => _navigateToDetailsPage(movie),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16.0),
        height: 400,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                movie['image']['original'] ?? movie['image']['medium'], // Use higher resolution
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                movie['name'] ?? 'Featured Movie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMovieSection(String title, Future<List<dynamic>> moviesFuture) {
    return FutureBuilder<List<dynamic>>(
      future: moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // No loader here; handled globally
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load $title movies', style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $title movies found', style: TextStyle(color: Colors.white)));
        }

        return MovieSection(
          sectionTitle: title,
          movies: snapshot.data!,
          onTap: (movie) => _navigateToDetailsPage(movie),
        );
      },
    );
  }
}

class MovieSection extends StatelessWidget {
  final String sectionTitle;
  final List<dynamic> movies;
  final Function(dynamic) onTap;

  MovieSection({required this.sectionTitle, required this.movies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            sectionTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1000, // Large number to create infinite scroll
            itemBuilder: (context, index) {
              var movie = movies[index % movies.length]['show']; // Loop through movies infinitely
              return MovieCard(
                title: movie['name'],
                imageUrl: movie['image']?['medium'] ?? 'https://via.placeholder.com/150',
                summary: movie['summary'] != null ? removeHtmlTags(movie['summary']) : 'No summary available',
                onTap: () => onTap(movie),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String summary;
  final Function() onTap;

  MovieCard({required this.title, required this.imageUrl, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              summary,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
