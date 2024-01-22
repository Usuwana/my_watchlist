import 'package:firebase_auth/firebase_auth.dart';
import '../utils/imports.dart';
import 'package:http/http.dart';
import 'dart:convert';

class APIseries {
  late String onAirTitle;
  late String onAirOverview;
  late String onAirPoster;
  String baseURL = "https://image.tmdb.org/t/p/original/";
  List<NetworkImage> onAirPosters = [];
  List<String> onAirPostersLinks = [];
  List<String> onAirTitles = [];
  List<String> onAirOverviews = [];
  List<dynamic> onAir = [];
  late String popularTitle;
  late String popularOverview;
  late String popularPoster;
  List<NetworkImage> popularPosters = [];
  List<String> popularPostersLinks = [];
  List<String> popularTitles = [];
  List<String> popularOverviews = [];
  List<dynamic> popular = [];

  late String ratedTitle;
  late String ratedOverview;
  late String ratedPoster;
  List<NetworkImage> ratedPosters = [];
  List<String> ratedPostersLinks = [];
  List<String> ratedTitles = [];
  List<String> ratedOverviews = [];
  List<dynamic> top_rated = [];

  List<dynamic> likedPosters = [];
  List<dynamic> likedTitles = [];
  List<dynamic> likedOverviews = [];
  List<dynamic> latest = [];

  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> addLiked(String poster, String title, String overview) async {
    /* firestoreInstance.collection("likedSeries").add({
      "title": title,
      "overview": overview,
      "poster": poster,
    }).then((value) {
      print(value.id);
    });*/
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("likedSeries")
            .add({
          "title": title,
          "overview": overview,
          "poster": poster,
        }).then((value) {
          print(value.id);
        });
      }
    });
  }

  void removeLiked(String title) {
    /*FirebaseFirestore.instance
        .collection("likedSeries")
        .where("title", isEqualTo: title)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("likedSeries")
            .doc(element.id)
            .delete()
            .then((value) {
          print("Success!");
        });
      });
    });*/
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("likedSeries")
            .where("title", isEqualTo: title)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("allow-users")
                .doc(user.uid)
                .collection("likedSeries")
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

  Future<dynamic> getLiked() async {
    /*CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("likedSeries");
    QuerySnapshot querySnapshot = await _collectionRef.get();

    likedTitles.addAll(querySnapshot.docs.map((doc) => doc["title"]).toList());
    likedOverviews
        .addAll(querySnapshot.docs.map((doc) => doc["overview"]).toList());
    likedPosters
        .addAll(querySnapshot.docs.map((doc) => doc["poster"]).toList());

    print(likedTitles);*/
    //FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    //if (user != null) {
    print("Success!");
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection("allow-users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("likedSeries");
    QuerySnapshot querySnapshot = await _collectionRef.get();

    likedTitles.addAll(querySnapshot.docs.map((doc) => doc["title"]).toList());
    likedOverviews
        .addAll(querySnapshot.docs.map((doc) => doc["overview"]).toList());
    likedPosters
        .addAll(querySnapshot.docs.map((doc) => doc["poster"]).toList());
    // print(likedTitles);
    // }
    //print(likedTitles);
    // });
    print(likedTitles);
    return likedPosters;
  }

  Future<dynamic> getOnAir() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/tv/on_the_air?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    onAir = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < onAir.length) {
          onAirTitle = data['results'][j]['name'];
          onAirOverview = data['results'][j]['overview'];
          onAirPoster = data['results'][j]['poster_path'];

          onAirTitles.add(onAirTitle);
          onAirOverviews.add(onAirOverview);
          onAirPosters.add(NetworkImage(baseURL + onAirPoster));
          onAirPostersLinks.add(onAirPoster);

          j++;
          i++;
        }
      }
    } else {
      throw new Exception("Could not get movies in play. Status code " +
          response.statusCode.toString());
    }
    return onAirPosters;
  }

  Future<dynamic> getMostPopular() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/tv/popular?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    popular = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < popular.length) {
          popularTitle = data['results'][j]['name'];
          popularOverview = data['results'][j]['overview'];
          popularPoster = data['results'][j]['poster_path'];
          popularTitles.add(popularTitle);
          popularOverviews.add(popularOverview);
          popularPosters.add(NetworkImage(baseURL + popularPoster));
          popularPostersLinks.add(popularPoster);

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

  Future<dynamic> getTopRated() async {
    Response response = await get(
      Uri.parse(
          'https://api.themoviedb.org/3/tv/top_rated?api_key=01654b20e22c2a6a6d22085d00bd3373'),
    );
    Map data = jsonDecode(response.body);
    top_rated = data['results'];

    int i = 0;
    int j = 0;

    if (response.statusCode == 200) {
      while (i < data.length) {
        while (j < top_rated.length) {
          ratedTitle = data['results'][j]['name'];
          ratedOverview = data['results'][j]['overview'];
          ratedPoster = data['results'][j]['poster_path'];
          ratedTitles.add(ratedTitle);
          ratedOverviews.add(ratedOverview);
          ratedPosters.add(NetworkImage(baseURL + ratedPoster));
          ratedPostersLinks.add(ratedPoster);
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
}
