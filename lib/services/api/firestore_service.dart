import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/modules/movie/model/movie.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _movieCollection => _firestore.collection('movies');
  Stream<List<Movie>> getPopularMovies() {
    return _movieCollection
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Movie>> getTVSeries() {
    return _movieCollection
        .where('type', isEqualTo: 'series')
        .limit(10)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  Future<List<Movie>> searchMovies(String query) async {
    final snapshot = await _movieCollection.get();
    final allMovies = snapshot.docs
        .map((docs) => Movie.fromFirestore(docs))
        .toList();
    return allMovies.where((movie) {
      return movie.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<bool> checkIfDataExists() async {
    final snapshot = await _movieCollection.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addMovie(Movie movie) async {
    await _movieCollection.add(movie.toFirestore());
  }

  Future<void> addSampleData() async {
    final sampleMovies = [
      Movie(
        id: '',
        title: 'Avengers',
        imageUrl:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400',
        genres: ['Adventure', 'Action'],
        type: 'movie',
        rating: 8.5,
        year: 2012,
        description:
            'Earth\'s mightiest heroes must come together to stop an alien invasion.',
        isPopular: true,
      ),
      Movie(
        id: '',
        title: 'Spider-Man',
        imageUrl:
            'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400',
        genres: ['Action', 'Comedy'],
        type: 'movie',
        rating: 8.0,
        year: 2021,
        description: 'Peter Parker\'s life and reputation are threatened.',
        isPopular: true,
      ),
      Movie(
        id: '',
        title: 'SEE',
        imageUrl:
            'https://images.unsplash.com/photo-1574267432644-f610f5b45e9c?w=400',
        genres: ['Action', 'Adventure'],
        type: 'series',
        rating: 7.6,
        year: 2019,
        description:
            'Far in a dystopian future, the human race has lost the sense of sight.',
        isPopular: false,
      ),
      Movie(
        id: '',
        title: 'THE LAKE',
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
        genres: ['Drama'],
        type: 'series',
        rating: 6.5,
        year: 2022,
        description:
            'A man returns to his cottage to reconnect with his biological daughter.',
        isPopular: false,
      ),
      Movie(
        id: '',
        title: 'MO',
        imageUrl:
            'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=400',
        genres: ['Comedy', 'Drama'],
        type: 'series',
        rating: 7.8,
        year: 2022,
        description:
            'Mo Najjar straddles the line between two cultures, three languages.',
        isPopular: false,
      ),
    ];
    for (var movie in sampleMovies) {
      await addMovie(movie);
    }
  }
}
