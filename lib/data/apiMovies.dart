import 'package:firebase_auth/firebase_auth.dart';
import '../utils/imports.dart';
import 'package:http/http.dart';
import 'dart:convert';

class APImovies {
  late String playingTitle = '';
  late String playingOverview = '';
  late String playingPoster = '';
  late int playingID = 0;
  String baseURL = "https://image.tmdb.org/t/p/original/";
  List<dynamic> playingPosters = [];
  List<int> playingIDs = [];
  List<String> playingPostersLink = [];
  List<String> playingTitles = [];
  List<String> playingOverviews = [];
  List<dynamic> nowPlaying = [];
  late String popularTitle = '';
  late String popularOverview = '';
  late String popularPoster = '';
  late int popularID = 0;
  List<dynamic> popularIDs = [];
  List<dynamic> popularPosters = [];
  List<String> popularPostersLink = [];
  List<String> popularTitles = [];
  List<String> popularOverviews = [];
  List<dynamic> popular = [];
  late String upcomingTitle = '';
  late String upcomingOverview = '';
  late String upcomingPoster = '';
  late int upcomingID = 0;
  List<int> upcomingIDs = [];
  List<dynamic> upcomingPosters = [];
  List<String> upcomingPostersLink = [];
  List<String> upcomingTitles = [];
  List<String> upcomingOverviews = [];
  List<dynamic> upcoming = [];
  late String ratedTitle;
  late String ratedOverview;
  late String ratedPoster;
  late int ratedID;
  List<int> ratedIDs = [];
  List<dynamic> ratedPosters = [];
  List<String> ratedPostersLink = [];
  List<String> ratedTitles = [];
  List<String> ratedOverviews = [];
  List<dynamic> top_rated = [];
  late String trendingTitle = '';
  late String trendingOverview = '';
  late String trendingPoster = '';
  late int trendingID = 0;
  List<int> trendingIDs = [];
  List<dynamic> trendingPosters = [];
  List<String> trendingPostersLink = [];
  List<String> trendingTitles = [];
  List<String> trendingOverviews = [];
  List<dynamic> likedPosters = [];
  List<dynamic> likedTitles = [];
  List<dynamic> likedOverviews = [];
  List<dynamic> likedIDs = [];
  List<dynamic> viewedPosters = [];
  List<dynamic> viewedTitles = [];
  List<dynamic> viewedOverviews = [];
  List<dynamic> viewedIDs = [];
  List<dynamic> trending = [];
  late String trailerKey;
  List<dynamic> trailerValues = [];
  late String trailer;

  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> addViewed(
      String poster, String title, String overview, int id) async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("viewedMovies")
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
          print("Aaaaaah" + value.id);
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
    print("This is it");
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
    likedIDs.addAll(querySnapshot.docs.map((doc) => doc["id"]).toList());
    print(likedPosters);

    print(likedPosters);
    return likedPosters;
  }

  Future<dynamic> getViewed() async {
    print("This is it");
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection("allow-users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("viewedMovies");
    QuerySnapshot querySnapshot = await _collectionRef.get();

    viewedTitles.addAll(querySnapshot.docs.map((doc) => doc["title"]).toList());

    viewedOverviews
        .addAll(querySnapshot.docs.map((doc) => doc["overview"]).toList());
    viewedPosters
        .addAll(querySnapshot.docs.map((doc) => doc["poster"]).toList());
    viewedIDs.addAll(querySnapshot.docs.map((doc) => doc["id"]).toList());
    print(viewedPosters);

    print(viewedPosters);
    return viewedPosters;
  }

  Future<dynamic> getNowPlaying() async {
    await getViewed();
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
          if (data['results'][j]['original_title'] == null) {
            playingTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['original_title'])) {
              playingTitle = data['results'][j]['original_title'];
            }
            //playingTitle = data['results'][j]['original_title'];
          }
          if (data['results'][j]['overview'] == null) {
            playingOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              playingOverview = data['results'][j]['overview'];
            }
            //playingOverview = data['results'][j]['overview'];
          }
          if (data['results'][j]['poster_path'] == null) {
            playingPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              playingPoster = data['results'][j]['poster_path'];
            }
            //playingPoster = data['results'][j]['poster_path'];
          }
          if (!viewedIDs.contains(data['results'][j]['id'])) {
            playingID = data['results'][j]['id'];
          }
          //playingID = data['results'][j]['id'];

          print("THESE THE ONES!");
          if (playingTitle != '') {
            playingTitles.add(playingTitle);
            playingOverviews.add(playingOverview);
            if (playingPoster == "assets/company_logo.png") {
              playingPosters.add(AssetImage(playingPoster));
              playingPostersLink.add(playingPoster);
            } else {
              playingPosters.add(NetworkImage(baseURL + playingPoster));
              playingPostersLink.add(playingPoster);
            }

            //playingPostersLink.add(playingPoster);
            playingIDs.add(playingID);
          }
          // playingTitles.add(playingTitle);
          // playingOverviews.add(playingOverview);
          // if (playingPoster == "assets/company_logo.png") {
          //   playingPosters.add(AssetImage(playingPoster));
          // } else {
          //   playingPosters.add(NetworkImage(baseURL + playingPoster));
          // }

          // playingPostersLink.add(playingPoster);
          // playingIDs.add(playingID);

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
    await getViewed();
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    popular = data['results'];

    int i = 0;
    int j = 0;

    // popularTitle = '';
    // popularID = 0;
    // popularOverview = '';
    // popularPoster = '';
    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < popular.length) {
          if (data['results'][j]['title'] == null) {
            popularTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['title'])) {
              popularTitle = data['results'][j]['title'];
            }
            //popularTitle = data['results'][j]['title'];
          }
          if (data['results'][j]['overview'] == null) {
            popularOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              popularOverview = data['results'][j]['overview'];
            }
          }
          //onAirPoster = "First";
          if (data['results'][j]['poster_path'] == null) {
            popularPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              popularPoster = data['results'][j]['poster_path'];
            }
          }

          if (!viewedIDs.contains(data['results'][j]['id'])) {
            popularID = data['results'][j]['id'];
          }
          // } else {
          //   popularID = data['results'][j]['id'];
          // }
          //print(popularID);

          if (popularTitle != '') {
            popularTitles.add(popularTitle);
            popularOverviews.add(popularOverview);
            popularIDs.add(popularID);
            if (popularPoster == "assets/company_logo.png") {
              popularPosters.add(AssetImage(popularPoster));
              popularPostersLink.add(popularPoster);
            } else {
              popularPosters.add(NetworkImage(baseURL + popularPoster));
              popularPostersLink.add(popularPoster);
            }
          }
          // if ((popularTitle != null) || (popularTitle != '')) {
          //   popularTitles.add(popularTitle);
          // }
          // if ((popularOverview != null) || (popularOverview != '')) {
          //   popularOverviews.add(popularOverview);
          // }

          // if (popularPoster == "assets/company_logo.png") {
          //   popularPosters.add(AssetImage(popularPoster));
          // } else {
          //   popularPosters.add(NetworkImage(baseURL + popularPoster));
          // }
          // if ((popularPoster != null) ||
          //     (popularPoster != '') ||
          //     (popularPoster != "assets/company_logo.png")) {
          //   popularPostersLink.add(popularPoster);
          // }
          // //popularPostersLink.add(popularPoster);
          // if ((popularID != null) || (popularID != '') || (popularID != 0)) {
          //   popularIDs.add(popularID);
          // }
          //popularIDs.add(popularID);
          //popularIDs.add(getTrailer(popularID));

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    print("These are the numbers fam:");
    print(popularTitles.length);
    print(popularOverviews.length);
    print(popularOverviews);
    print(popularIDs.length);
    print(popularIDs);
    print(popularPosters.length);
    print(popularPosters);
    return popularPosters;
  }

  Future<dynamic> getUpcoming() async {
    await getViewed();
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
          if (data['results'][j]['original_title'] == null) {
            upcomingTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['original_title'])) {
              upcomingTitle = data['results'][j]['original_title'];
            }
            //upcomingTitle = data['results'][j]['original_title'];
          }
          if (data['results'][j]['overview'] == null) {
            upcomingOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              upcomingOverview = data['results'][j]['overview'];
            }
            //upcomingOverview = data['results'][j]['overview'];
          }
          //onAirPoster = "First";
          if (data['results'][j]['poster_path'] == null) {
            upcomingPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              upcomingPoster = data['results'][j]['poster_path'];
            }
            //upcomingPoster = data['results'][j]['poster_path'];
          }
          if (!viewedIDs.contains(data['results'][j]['id'])) {
            upcomingID = data['results'][j]['id'];
          }
          //upcomingID = data['results'][j]['id'];

          // for (var k = 0; i < upcoming.length; i++) {
          // if (upcomingTitle != likedTitles[k].toString()) {
          if (upcomingTitle != '') {
            upcomingTitles.add(upcomingTitle);
            upcomingOverviews.add(upcomingOverview);
            if (upcomingPoster == "assets/company_logo.png") {
              upcomingPosters.add(AssetImage(upcomingPoster));
              upcomingPostersLink.add(upcomingPoster);
            } else {
              upcomingPosters.add(NetworkImage(baseURL + upcomingPoster));
              upcomingPostersLink.add(upcomingPoster);
            }

            //upcomingPostersLink.add(upcomingPoster);
            upcomingIDs.add(upcomingID);
          }
          // upcomingTitles.add(upcomingTitle);
          // upcomingOverviews.add(upcomingOverview);
          // if (upcomingPoster == "assets/company_logo.png") {
          //   upcomingPosters.add(AssetImage(upcomingPoster));
          // } else {
          //   upcomingPosters.add(NetworkImage(baseURL + upcomingPoster));
          // }

          // upcomingPostersLink.add(upcomingPoster);
          // upcomingIDs.add(upcomingID);

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
    await getViewed();
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
          if (data['results'][j]['original_title'] == null) {
            ratedTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['original_title'])) {
              ratedTitle = data['results'][j]['original_title'];
            }
            //ratedTitle = data['results'][j]['original_title'];
          }
          if (data['results'][j]['overview'] == null) {
            ratedOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              ratedOverview = data['results'][j]['overview'];
            }
            //ratedOverview = data['results'][j]['overview'];
          }
          //onAirPoster = "First";
          if (data['results'][j]['poster_path'] == null) {
            ratedPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              ratedPoster = data['results'][j]['poster_path'];
            }
            //ratedPoster = data['results'][j]['poster_path'];
          }

          if (!viewedIDs.contains(data['results'][j]['id'])) {
            ratedID = data['results'][j]['id'];
          }
          //ratedID = data['results'][j]['id'];

          if (ratedTitle != '') {
            ratedTitles.add(ratedTitle);
            ratedOverviews.add(ratedOverview);
            if (ratedPoster == "assets/company_logo.png") {
              ratedPosters.add(AssetImage(ratedPoster));
              ratedPostersLink.add(ratedPoster);
            } else {
              ratedPosters.add(NetworkImage(baseURL + ratedPoster));
              ratedPostersLink.add(ratedPoster);
            }

            //ratedPostersLink.add(ratedPoster);
            ratedIDs.add(ratedID);
          }
          // ratedTitles.add(ratedTitle);
          // ratedOverviews.add(ratedOverview);
          // if (ratedPoster == "assets/company_logo.png") {
          //   ratedPosters.add(AssetImage(ratedPoster));
          // } else {
          //   ratedPosters.add(NetworkImage(baseURL + ratedPoster));
          // }

          // ratedPostersLink.add(ratedPoster);
          // ratedIDs.add(ratedID);

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
    await getViewed();
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
          if (data['results'][j]['title'] == null) {
            trendingTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['title'])) {
              trendingTitle = data['results'][j]['title'];
            }
            //trendingTitle = data['results'][j]['title'];
          }
          if (data['results'][j]['overview'] == null) {
            trendingOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              trendingOverview = data['results'][j]['overview'];
            }
            //trendingOverview = data['results'][j]['overview'];
          }
          //onAirPoster = "First";
          if (data['results'][j]['poster_path'] == null) {
            trendingPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              trendingPoster = data['results'][j]['poster_path'];
            }
            //trendingPoster = data['results'][j]['poster_path'];
          }

          if (!viewedIDs.contains(data['results'][j]['id'])) {
            trendingID = data['results'][j]['id'];
          }
          //trendingID = data['results'][j]['id'];

          if (trendingTitle != '') {
            trendingTitles.add(trendingTitle);
            trendingOverviews.add(trendingOverview);
            if (trendingPoster == "assets/company_logo.png") {
              trendingPosters.add(AssetImage(trendingPoster));
            } else {
              trendingPosters.add(NetworkImage(baseURL + trendingPoster));
            }

            trendingPostersLink.add(trendingPoster);
            trendingIDs.add(trendingID);
          }
          // trendingTitles.add(trendingTitle);
          // trendingOverviews.add(trendingOverview);
          // if (trendingPoster == "assets/company_logo.png") {
          //   trendingPosters.add(AssetImage(trendingPoster));
          // } else {
          //   trendingPosters.add(NetworkImage(baseURL + trendingPoster));
          // }

          // trendingPostersLink.add(trendingPoster);
          // trendingIDs.add(trendingID);

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
