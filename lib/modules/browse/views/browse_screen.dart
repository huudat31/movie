import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/views/detail_screen.dart';
import 'package:movie_app/modules/movie/views/genre_movies_screen.dart';
import 'package:movie_app/services/tmdb/tmdb_service.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TMDBService _tmdbService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tmdbService = TMDBService();
    debugPrint('🔍 BrowseScreen initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tmdbService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildMoviesTab(), _buildTVShowsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Browse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Filter
            },
            icon: const Icon(Icons.tune, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Movies'),
          Tab(text: 'TV Shows'),
        ],
      ),
    );
  }

  Widget _buildMoviesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Popular Genres'),
          _buildGenresGrid(false),
          const SizedBox(height: 24),
          _buildSectionTitle('Trending Now'),
          _buildTrendingMovies(),
          const SizedBox(height: 24),
          _buildSectionTitle('Top Rated'),
          _buildTopRatedMovies(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTVShowsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Popular Genres'),
          _buildGenresGrid(true),
          const SizedBox(height: 24),
          _buildSectionTitle('Popular TV Shows'),
          _buildPopularTVShows(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGenresGrid(bool isTVShow) {
    final genres = isTVShow
        ? [
            {'id': 10759, 'name': 'Action & Adventure', 'icon': '⚔️'},
            {'id': 16, 'name': 'Animation', 'icon': '🎨'},
            {'id': 35, 'name': 'Comedy', 'icon': '😂'},
            {'id': 80, 'name': 'Crime', 'icon': '🔫'},
            {'id': 99, 'name': 'Documentary', 'icon': '📹'},
            {'id': 18, 'name': 'Drama', 'icon': '🎭'},
            {'id': 10751, 'name': 'Family', 'icon': '👨‍👩‍👧‍👦'},
            {'id': 10762, 'name': 'Kids', 'icon': '👶'},
            {'id': 9648, 'name': 'Mystery', 'icon': '🔍'},
            {'id': 10765, 'name': 'Sci-Fi & Fantasy', 'icon': '🚀'},
          ]
        : [
            {'id': 28, 'name': 'Action', 'icon': '💥'},
            {'id': 12, 'name': 'Adventure', 'icon': '🗺️'},
            {'id': 16, 'name': 'Animation', 'icon': '🎨'},
            {'id': 35, 'name': 'Comedy', 'icon': '😂'},
            {'id': 80, 'name': 'Crime', 'icon': '🔫'},
            {'id': 99, 'name': 'Documentary', 'icon': '📹'},
            {'id': 18, 'name': 'Drama', 'icon': '🎭'},
            {'id': 10751, 'name': 'Family', 'icon': '👨‍👩‍👧‍👦'},
            {'id': 14, 'name': 'Fantasy', 'icon': '🧙'},
            {'id': 27, 'name': 'Horror', 'icon': '👻'},
            {'id': 10749, 'name': 'Romance', 'icon': '❤️'},
            {'id': 878, 'name': 'Sci-Fi', 'icon': '🚀'},
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return _buildGenreCard(
          genre['name'] as String,
          genre['icon'] as String,
          genre['id'] as int,
          isTVShow,
        );
      },
    );
  }

  Widget _buildGenreCard(String name, String icon, int genreId, bool isTVShow) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenreMoviesScreen(
              genreId: genreId,
              genreName: name,
              isTVShow: isTVShow,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35).withOpacity(0.3),
              Colors.grey[900]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingMovies() {
    return FutureBuilder<List<TMDBMovie>>(
      future: _tmdbService.getNowPlayingMovies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
          );
        }
        return _buildHorizontalList(snapshot.data!);
      },
    );
  }

  Widget _buildTopRatedMovies() {
    return FutureBuilder<List<TMDBMovie>>(
      future: _tmdbService.getTopRatedMovies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
          );
        }
        return _buildHorizontalList(snapshot.data!);
      },
    );
  }

  Widget _buildPopularTVShows() {
    return FutureBuilder<List<TMDBMovie>>(
      future: _tmdbService.getPopularTVShows(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
          );
        }
        return _buildHorizontalList(snapshot.data!);
      },
    );
  }

  Widget _buildHorizontalList(List<TMDBMovie> movies) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return _buildMovieCard(movies[index]);
        },
      ),
    );
  }

  Widget _buildMovieCard(TMDBMovie movie) {
    final posterUrl = TMDBService.getPosterUrl(movie.posterPath);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TMDBDetailScreen(movie: movie)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: posterUrl,
                height: 160,
                width: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
