import 'package:cloud_firestore/cloud_firestore.dart';

class Showtime {
  final String id;
  final int movieId;
  final String cinemaId;
  final DateTime startTime;
  final double price;
  final String format; // 2D, 3D, IMAX
  final List<String> bookedSeats;

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.startTime,
    required this.price,
    required this.format,
    this.bookedSeats = const [],
  });

  factory Showtime.fromMap(Map<String, dynamic> map, String id) {
    return Showtime(
      id: id,
      movieId: map['movieId'] ?? 0,
      cinemaId: map['cinemaId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      price: (map['price'] ?? 0).toDouble(),
      format: map['format'] ?? '2D',
      bookedSeats: List<String>.from(map['bookedSeats'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'cinemaId': cinemaId,
      'startTime': Timestamp.fromDate(startTime),
      'price': price,
      'format': format,
      'bookedSeats': bookedSeats,
    };
  }
}
