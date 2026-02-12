import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String userId;
  final String showtimeId;
  final int movieId;
  final String movieTitle;
  final String cinemaName;
  final DateTime startTime;
  final List<String> seats;
  final double totalAmount;
  final String status; // pending, paid, cancelled
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaName,
    required this.startTime,
    required this.seats,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory Ticket.fromMap(Map<String, dynamic> map, String id) {
    return Ticket(
      id: id,
      userId: map['userId'] ?? '',
      showtimeId: map['showtimeId'] ?? '',
      movieId: map['movieId'] ?? 0,
      movieTitle: map['movieTitle'] ?? '',
      cinemaName: map['cinemaName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      seats: List<String>.from(map['seats'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'showtimeId': showtimeId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'startTime': Timestamp.fromDate(startTime),
      'seats': seats,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
