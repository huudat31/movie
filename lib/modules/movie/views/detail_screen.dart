import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app/modules/movie/model/tmdb_genre.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/model/tmdb_video.dart';
import 'package:movie_app/services/tmdb/tmdb_service.dart';
import 'package:movie_app/services/tmdb/watch_list_service.dart';
import 'video_player_screen.dart';

class TMDBDetailScreen extends StatefulWidget {
  final TMDBMovie movie;

  const TMDBDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<TMDBDetailScreen> createState() => _TMDBDetailScreenState();
}

class _TMDBDetailScreenState extends State<TMDBDetailScreen> {
  late final TMDBService _tmdbService;
  final WatchlistService _watchlistService = WatchlistService();
  List<TMDBVideo> _videos = [];
  bool _isLoading = true;
  bool _isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    _tmdbService = TMDBService();
    _loadData();
    debugPrint('🎬 TMDBDetailScreen initialized');
  }

  Future<void> _loadData() async {
    await Future.wait([_loadVideos(), _checkWatchlist()]);
  }

  Future<void> _loadVideos() async {
    try {
      final videos = widget.movie.isTVShow
          ? await _tmdbService.getTVShowVideos(widget.movie.id)
          : await _tmdbService.getMoviesVideos(widget.movie.id);

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading videos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkWatchlist() async {
    final inWatchlist = await _watchlistService.isInWatchlist(widget.movie.id);
    setState(() => _isInWatchlist = inWatchlist);
  }

  Future<void> _toggleWatchlist() async {
    if (_isInWatchlist) {
      await _watchlistService.removeFromWatchlist(widget.movie.id);
    } else {
      await _watchlistService.addToWatchlist(widget.movie);
    }
    await _checkWatchlist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist',
          ),
          backgroundColor: const Color(0xFFFF6B35),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tmdbService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdropUrl = TMDBService.getBackdropUrl(widget.movie.backdropPath);
    final genres = TmdbGenre.getGenreNames(
      widget.movie.genreIds,
      isTVShow: widget.movie.isTVShow,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(backdropUrl),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildInfoRow(),
                  const SizedBox(height: 16),
                  _buildGenres(genres),
                  const SizedBox(height: 24),
                  _buildRating(),
                  const SizedBox(height: 24),
                  _buildOverview(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  if (_videos.isNotEmpty) _buildVideosSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String backdropUrl) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.movie.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.movie.year,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          widget.movie.formatterVoteAverage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.movie.isTVShow ? 'TV SHOW' : 'MOVIE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(List<String> genres) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        return Chip(
          label: Text(genre),
          backgroundColor: Colors.grey[800],
          labelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
      }).toList(),
    );
  }

  Widget _buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            RatingBarIndicator(
              rating: widget.movie.rating,
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 30,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 16),
            Text(
              '${widget.movie.formatterVoteAverage}/10',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.movie.voteCount} votes)',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.movie.overview.isNotEmpty
              ? widget.movie.overview
              : 'No overview available.',
          style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _videos.isNotEmpty ? _playTrailer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              disabledBackgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              _videos.isEmpty ? 'No Trailer' : 'Play Trailer',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _toggleWatchlist,
            icon: Icon(
              _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              color: _isInWatchlist ? const Color(0xFFFF6B35) : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Share functionality
            },
            icon: const Icon(Icons.share, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trailers & Videos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              return _buildVideoCard(_videos[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(TMDBVideo video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: 200,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 48,
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                video.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playTrailer() {
    if (_videos.isNotEmpty) {
      _playVideo(_videos.first);
    }
  }

  void _playVideo(TMDBVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VideoPlayerScreen(videoKey: video.key, title: video.name),
      ),
    );
  }
}
