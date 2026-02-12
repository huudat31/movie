import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/modules/booking/model/showtime.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'payment_webview_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TMDBMovie movie;
  final Showtime showtime;
  final String cinemaName;

  const SeatSelectionScreen({
    Key? key,
    required this.movie,
    required this.showtime,
    required this.cinemaName,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  late final List<String> _rows;
  late final int _cols;

  @override
  void initState() {
    super.initState();
    _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    _cols = 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Seats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildScreenIndicator(),
          const SizedBox(height: 40),
          Expanded(child: _buildSeatGrid()),
          _buildLegend(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        Container(
          height: 4,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'SCREEN',
          style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 4),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: _rows.map((row) {
            return Row(
              children: List.generate(_cols, (index) {
                final seatId = '$row${index + 1}';
                final isBooked = widget.showtime.bookedSeats.contains(seatId);
                final isSelected = _selectedSeats.contains(seatId);

                return GestureDetector(
                  onTap: isBooked ? null : () => _toggleSeat(seatId),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey[800]
                          : isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isBooked
                            ? Colors.transparent
                            : isSelected
                            ? Colors.transparent
                            : Colors.white30,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        seatId,
                        style: TextStyle(
                          fontSize: 8,
                          color: isBooked
                              ? Colors.grey[600]
                              : isSelected
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleSeat(String seatId) {
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Available', Colors.transparent, border: true),
          const SizedBox(width: 20),
          _buildLegendItem('Selected', const Color(0xFFFF6B35)),
          const SizedBox(width: 20),
          _buildLegendItem('Booked', Colors.grey[800]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: Colors.white30) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomBar() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final totalPrice = _selectedSeats.length * widget.showtime.price;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedSeats.length} Seats: ${_selectedSeats.join(', ')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(totalPrice),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _selectedSeats.isEmpty ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              disabledBackgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebviewScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          cinemaName: widget.cinemaName,
          selectedSeats: _selectedSeats,
          totalAmount: _selectedSeats.length * widget.showtime.price,
        ),
      ),
    );
  }
}
