import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> genres;
  final String type;
  final double rating;
  final int year;
  final String description;
  final bool isPopular;

  const Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genres,
    required this.type,
    this.rating = 0.0,
    this.year = 2024,
    this.description = '',
    this.isPopular = false,
  });

  // Convert from Firestore
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      type: data['type'] ?? 'movie',
      rating: (data['rating'] ?? 0).toDouble(),
      year: data['year'] ?? 2024,
      description: data['description'] ?? '',
      isPopular: data['isPopular'] ?? false,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'genres': genres,
      'type': type,
      'rating': rating,
      'year': year,
      'description': description,
      'isPopular': isPopular,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, title, imageUrl, genres, type, rating, year];
}
