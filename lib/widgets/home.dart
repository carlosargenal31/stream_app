import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stream_app/clases/movie.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamController<List<Movie>> _streamController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _streamController = StreamController<List<Movie>>();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMovies();
    });
  }

  Future<void> fetchMovies() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=a414fbf7aed71ff115a6d64940233dc3'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Movie> movies = (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();

      _streamController.add(movies);
    } else {
      _streamController.addError('Error en la solicitud');
    }
  }

  @override
  void dispose() {
    _streamController.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDb Peliculas Populares'),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return MovieListItem(movie: snapshot.data![index]);
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(snapshot.error?.toString() ?? 'Error desconocido'),
            );
          }
        },
      ),
    );
  }
}

class MovieListItem extends StatelessWidget {
  final Movie movie;

  const MovieListItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(movie.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${movie.id}'),
            Text('Fecha de lanzamiento: ${movie.releaseDate}'),
            Text('Puntuación: ${movie.voteAverage}'),
          ],
        ),
      ),
    );
  }
}
