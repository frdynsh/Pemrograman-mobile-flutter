class Movie {
  final String title;
  final String overview;
  final String posterPath; 
  
  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
  });

  // Parsing JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No Description',
      posterPath: "https://image.tmdb.org/t/p/w500${json['poster_path'] ?? ''}",
    );
  }
}