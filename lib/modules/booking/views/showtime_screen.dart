import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/modules/booking/model/cinema.dart';
import 'package:movie_app/modules/booking/model/showtime.dart';
import 'package:movie_app/services/booking/booking_service.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'seat_selection_screen.dart';

class ShowtimeScreen extends StatefulWidget {
  final TMDBMovie movie;

  const ShowtimeScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<ShowtimeScreen> createState() => _ShowtimeScreenState();
}

class _ShowtimeScreenState extends State<ShowtimeScreen> {
  final BookingService _bookingService = BookingService();
  DateTime _selectedDate = DateTime.now();
  List<Showtime> _showtimes = [];
  List<Cinema> _cinemas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cinemas = await _bookingService.getCinemas();
    final showtimes = await _bookingService.getShowtimes(
      widget.movie.id,
      _selectedDate,
    );

    if (mounted) {
      setState(() {
        _cinemas = cinemas;
        _showtimes = showtimes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Select Showtime',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const Divider(color: Colors.white10),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  )
                : _showtimes.isEmpty
                ? const Center(
                    child: Text(
                      'No showtimes available for this day.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildCinemaList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _loadData();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCinemaList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cinemas.length,
      itemBuilder: (context, index) {
        final cinema = _cinemas[index];
        final cinemaShowtimes = _showtimes
            .where((s) => s.cinemaId == cinema.id)
            .toList();

        if (cinemaShowtimes.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.movie_creation_outlined,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cinema.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                cinema.address,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cinemaShowtimes
                    .map((showtime) => _buildTimeSlot(showtime, cinema.name))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlot(Showtime showtime, String cinemaName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeatSelectionScreen(
              movie: widget.movie,
              showtime: showtime,
              cinemaName: cinemaName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('HH:mm').format(showtime.startTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              showtime.format,
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
