import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'movie_model.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final String _apiKey = "cf3d30804868074c3363550d6279a9e0";

  late Future<List<Movie>> _futureMovies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureMovies = _fetchNowPlaying();
  }

  // Fetch Now Playing
  Future<List<Movie>> _fetchNowPlaying() async {
    final url = Uri.parse(
      "https://api.themoviedb.org/3/movie/now_playing?api_key=$_apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final List results = data["results"];
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // Search Movie
  Future<List<Movie>> _searchMovie(String query) async {
    if (query.isEmpty) return _fetchNowPlaying();

    final url = Uri.parse(
      "https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final List results = data["results"];
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  void _onSearch() {
    setState(() {
      _futureMovies = _searchMovie(_searchController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B0A14), // Pink gelap elegan
      appBar: AppBar(
        backgroundColor: const Color(0xff1B0A14),
        elevation: 0,
        title: const Text(
          "🎬 Now Playing",
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),

      // ---------------- SEARCH BAR ----------------
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pinkAccent.withOpacity(0.3),
                          Colors.pink.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.pinkAccent),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Cari film...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),

          // ---------------- MOVIE LIST ----------------
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _futureMovies,
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pinkAccent),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final movies = snapshot.data ?? [];

                if (movies.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada film ditemukan",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                // LIST VIEW
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final poster =
                        "https://image.tmdb.org/t/p/w500${movie.posterPath}";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Colors.pinkAccent.withOpacity(0.25),
                            Colors.pink.withOpacity(0.08),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Row(
                          children: [
                            // POSTER
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                poster,
                                width: 110,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // TITLE + OVERVIEW
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 14,
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      movie.overview,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
