import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/modules/booking/model/cinema.dart';
import 'package:movie_app/modules/booking/model/showtime.dart';
import 'package:movie_app/modules/booking/model/ticket.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _cinemasRef => _firestore.collection('cinemas');
  CollectionReference get _showtimesRef => _firestore.collection('showtimes');
  CollectionReference get _ticketsRef => _firestore.collection('tickets');

  String? get _userId => _auth.currentUser?.uid;

  // ============ CINEMAS ============

  Future<List<Cinema>> getCinemas() async {
    try {
      final snapshot = await _cinemasRef.get();
      return snapshot.docs
          .map(
            (doc) => Cinema.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting cinemas: $e');
      return [];
    }
  }

  // ============ SHOWTIMES ============

  Future<List<Showtime>> getShowtimes(int movieId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _showtimesRef
          .where('movieId', isEqualTo: movieId)
          .where(
            'startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (snapshot.docs.isEmpty) {
        // If no showtimes, auto-generate some for demo purposes
        await _generateShowtimesForMovie(movieId, date);
        return getShowtimes(movieId, date); // Recursively call once
      }

      return snapshot.docs
          .map(
            (doc) =>
                Showtime.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting showtimes: $e');
      return [];
    }
  }

  Future<void> _generateShowtimesForMovie(int movieId, DateTime date) async {
    try {
      final cinemas = await getCinemas();
      if (cinemas.isEmpty) {
        await _seedInitialCinemas();
        return _generateShowtimesForMovie(movieId, date);
      }

      final writeBatch = _firestore.batch();
      final formats = ['2D', '3D', 'IMAX'];
      final times = [
        const Duration(hours: 10, minutes: 0),
        const Duration(hours: 13, minutes: 30),
        const Duration(hours: 16, minutes: 0),
        const Duration(hours: 19, minutes: 30),
        const Duration(hours: 22, minutes: 0),
      ];

      for (var cinema in cinemas) {
        for (var time in times) {
          final startTime = DateTime(date.year, date.month, date.day).add(time);
          if (startTime.isBefore(DateTime.now())) continue;

          final showtime = Showtime(
            id: '',
            movieId: movieId,
            cinemaId: cinema.id,
            startTime: startTime,
            price:
                75000 +
                (formats.indexOf('2D') * 20000).toDouble(), // Simple pricing
            format: '2D', // Default for now
          );

          final docRef = _showtimesRef.doc();
          writeBatch.set(docRef, showtime.toMap());
        }
      }

      await writeBatch.commit();
      debugPrint(
        '✅ Auto-generated showtimes for movie $movieId on ${date.toIso8601String()}',
      );
    } catch (e) {
      debugPrint('❌ Error generating showtimes: $e');
    }
  }

  Future<void> _seedInitialCinemas() async {
    final initialCinemas = [
      Cinema(
        id: 'cgv_vincom',
        name: 'CGV Vincom Center',
        address: '72 Lê Thánh Tôn, Bến Nghé, Q1',
      ),
      Cinema(
        id: 'lotte_cantavil',
        name: 'Lotte Cinema Cantavil',
        address: 'Số 1 Song Hành, An Phú, Q2',
      ),
      Cinema(
        id: 'bhd_bitexco',
        name: 'BHD Star Bitexco',
        address: '39-45 Ngô Đức Kế, Bến Nghé, Q1',
      ),
    ];

    for (var cinema in initialCinemas) {
      await _cinemasRef.doc(cinema.id).set(cinema.toMap());
    }
  }

  // ============ BOOKING ============

  Future<String> createBooking(Ticket ticket) async {
    try {
      final docRef = await _ticketsRef.add(ticket.toMap());

      // Update bookedSeats in Showtime
      await _showtimesRef.doc(ticket.showtimeId).update({
        'bookedSeats': FieldValue.arrayUnion(ticket.seats),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating booking: $e');
      rethrow;
    }
  }

  Stream<List<Ticket>> getUserTickets() {
    if (_userId == null) return Stream.value([]);

    return _ticketsRef
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Ticket.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }
}
