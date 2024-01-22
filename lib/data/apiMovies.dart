import 'package:firebase_auth/firebase_auth.dart';
import '../utils/imports.dart';
import 'package:http/http.dart';
import 'dart:convert';

class APImovies {
  late String playingTitle;
  late String playingOverview;
  late String playingPoster;
  late int playingID;
  String baseURL = "https://image.tmdb.org/t/p/original/";
  List<NetworkImage> playingPosters = [];
  List<int> playingIDs = [];
  List<String> playingPostersLink = [];
  List<String> playingTitles = [];
  List<String> playingOverviews = [];
  List<dynamic> nowPlaying = [];
  late String popularTitle;
  late String popularOverview;
  late String popularPoster;
  late int popularID;
  List<dynamic> popularIDs = [];
  List<NetworkImage> popularPosters = [];
  List<String> popularPostersLink = [];
  List<String> popularTitles = [];
  List<String> popularOverviews = [];
  List<dynamic> popular = [];
  late String upcomingTitle;
  late String upcomingOverview;
  late String upcomingPoster;
  late int upcomingID;
  List<int> upcomingIDs = [];
  List<NetworkImage> upcomingPosters = [];
  List<String> upcomingPostersLink = [];
  List<String> upcomingTitles = [];
  List<String> upcomingOverviews = [];
  List<dynamic> upcoming = [];
  late String ratedTitle;
  late String ratedOverview;
  late String ratedPoster;
  late int ratedID;
  List<int> ratedIDs = [];
  List<NetworkImage> ratedPosters = [];
  List<String> ratedPostersLink = [];
  List<String> ratedTitles = [];
  List<String> ratedOverviews = [];
  List<dynamic> top_rated = [];
  late String trendingTitle;
  late String trendingOverview;
  late String trendingPoster;
  late int trendingID;
  List<int> trendingIDs = [];
  List<NetworkImage> trendingPosters = [];
  List<String> trendingPostersLink = [];
  List<String> trendingTitles = [];
  List<String> trendingOverviews = [];
  List<dynamic> likedPosters = [];
  List<dynamic> likedTitles = [];
  List<dynamic> likedOverviews = [];
  List<int> likedIDs = [];
  List<dynamic> trending = [];
  late String trailerKey;
  List<dynamic> trailerValues = [];
  late String trailer;

  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> addLiked(
      String poster, String title, String overview, int id) async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("likedMovies")
            .add({
          "title": title,
          "overview": overview,
          "poster": poster,
          "id": id
        }).then((value) {
          print(value.id);
        });
      }
    });
  }

  void removeLiked(String title) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("likedMovies")
            .where("title", isEqualTo: title)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("allow-users")
                .doc(user.uid)
                .collection("likedMovies")
                .doc(element.id)
                .delete()
                .then((value) {
              print("Success!");
            });
          });
        });
      }
    });
  }

  Future<dynamic> getTrailer(int id) async {
    Response response = await get(
      Uri.parse(
          'http://api.themoviedb.org/3/movie/${id}/videos?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    trailerValues = data['results'];
    //trailerKey = data['results']['key'];
    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < nowPlaying.length) {
          if (data['results'][j]['type'] == "Trailer") {
            trailerKey = data['results'][j]['id'];
          }
        }
      }
    }
    print('https://www.youtube.com/watch?v=${trailerKey}');
    trailer = 'https://www.youtube.com/watch?v=${trailerKey}';
    return trailer;
  }

  Future<dynamic> getLiked() async {
    print("Success!");
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection("allow-users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("likedMovies");
    QuerySnapshot querySnapshot = await _collectionRef.get();

    likedTitles.addAll(querySnapshot.docs.map((doc) => doc["title"]).toList());
    print(likedTitles);
    likedOverviews
        .addAll(querySnapshot.docs.map((doc) => doc["overview"]).toList());
    likedPosters
        .addAll(querySnapshot.docs.map((doc) => doc["poster"]).toList());
    print(likedPosters);

    print(likedPosters);
    return likedPosters;
  }

  Future<dynamic> getNowPlaying() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/now_playing?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    nowPlaying = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < nowPlaying.length) {
          playingTitle = data['results'][j]['original_title'];
          playingOverview = data['results'][j]['overview'];
          playingPoster = data['results'][j]['poster_path'];
          playingID = data['results'][j]['id'];

          print("THESE THE ONES!");
          playingTitles.add(playingTitle);
          playingOverviews.add(playingOverview);
          playingPosters.add(NetworkImage(baseURL + playingPoster));
          playingPostersLink.add(playingPoster);
          playingIDs.add(playingID);

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    return playingPosters;
  }

  Future<dynamic> getMostPopular() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    popular = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < popular.length) {
          popularTitle = data['results'][j]['title'];
          popularOverview = data['results'][j]['overview'];
          popularPoster = data['results'][j]['poster_path'];
          popularID = data['results'][j]['id'];
          print(popularID);
          popularTitles.add(popularTitle);
          popularOverviews.add(popularOverview);
          popularPosters.add(NetworkImage(baseURL + popularPoster));
          popularPostersLink.add(popularPoster);
          popularIDs.add(popularID);
          //popularIDs.add(getTrailer(popularID));

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    return popularPosters;
  }

  Future<dynamic> getUpcoming() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/upcoming?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    upcoming = data['results'];

    int i = 0;
    int j = 0;
    getLiked();
    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < upcoming.length) {
          upcomingTitle = data['results'][j]['original_title'];
          upcomingOverview = data['results'][j]['overview'];
          upcomingPoster = data['results'][j]['poster_path'];
          upcomingID = data['results'][j]['id'];

          // for (var k = 0; i < upcoming.length; i++) {
          // if (upcomingTitle != likedTitles[k].toString()) {
          upcomingTitles.add(upcomingTitle);
          upcomingOverviews.add(upcomingOverview);
          upcomingPosters.add(NetworkImage(baseURL + upcomingPoster));
          upcomingPostersLink.add(upcomingPoster);
          upcomingIDs.add(upcomingID);

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }

    return upcomingPosters;
  }

  Future<dynamic> getTopRated() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/top_rated?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    top_rated = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < top_rated.length) {
          ratedTitle = data['results'][j]['original_title'];
          ratedOverview = data['results'][j]['overview'];
          ratedPoster = data['results'][j]['poster_path'];
          ratedID = data['results'][j]['id'];
          ratedTitles.add(ratedTitle);
          ratedOverviews.add(ratedOverview);
          ratedPosters.add(NetworkImage(baseURL + ratedPoster));
          ratedPostersLink.add(ratedPoster);
          ratedIDs.add(ratedID);

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    return ratedPosters;
  }

  Future<dynamic> getTrending() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/trending/all/day?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    trending = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < trending.length) {
          trendingTitle = data['results'][j]['title'];
          trendingOverview = data['results'][j]['overview'];
          trendingPoster = data['results'][j]['poster_path'];
          trendingID = data['results'][j]['id'];
          trendingTitles.add(trendingTitle);
          trendingOverviews.add(trendingOverview);
          trendingPosters.add(NetworkImage(baseURL + trendingPoster));
          trendingPostersLink.add(trendingPoster);
          trendingIDs.add(trendingID);

          print(trendingTitles);
          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    return trendingPosters;
  }
}
