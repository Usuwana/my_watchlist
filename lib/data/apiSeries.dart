import 'package:firebase_auth/firebase_auth.dart';
import '../utils/imports.dart';
import 'package:http/http.dart';
import 'dart:convert';

class APIseries {
  late String onAirTitle = '';
  late String onAirOverview = '';
  late String onAirPoster = '';
  late int onAirID = 0;
  String baseURL = "https://image.tmdb.org/t/p/original/";
  List<dynamic> onAirPosters = [];
  List<String> onAirPostersLinks = [];
  List<String> onAirTitles = [];
  List<String> onAirOverviews = [];
  List<int> onAirIDs = [];
  List<dynamic> onAir = [];
  late String popularTitle = '';
  late String popularOverview = '';
  late String popularPoster = '';
  late int popularID = 0;
  List<dynamic> popularPosters = [];
  List<String> popularPostersLinks = [];
  List<String> popularTitles = [];
  List<String> popularOverviews = [];
  List<dynamic> popularIDs = [];
  List<dynamic> popular = [];

  late String ratedTitle = '';
  late String ratedOverview = '';
  late String ratedPoster = '';
  late int ratedID = 0;
  List<dynamic> ratedPosters = [];
  List<String> ratedPostersLinks = [];
  List<String> ratedTitles = [];
  List<String> ratedOverviews = [];
  List<int> ratedIDs = [];
  List<dynamic> top_rated = [];

  List<dynamic> likedPosters = [];
  List<dynamic> likedTitles = [];
  List<dynamic> likedOverviews = [];
  List<dynamic> likedIDs = [];
  List<dynamic> latest = [];

  List<dynamic> viewedPosters = [];
  List<dynamic> viewedTitles = [];
  List<dynamic> viewedOverviews = [];
  List<dynamic> viewedIDs = [];

  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> addViewed(
      String poster, String title, String overview, int id) async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        firestoreInstance
            .collection("allow-users")
            .doc(user.uid)
            .collection("viewedSeries")
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
          "id": id
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
    likedIDs.addAll(querySnapshot.docs.map((doc) => doc["id"]).toList());
    // print(likedTitles);
    // }
    //print(likedTitles);
    // });
    print(likedTitles);
    return likedPosters;
  }

  Future<dynamic> getViewed() async {
    print("This is it");
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection("allow-users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("viewedSeries");
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

  Future<dynamic> getOnAir() async {
    await getViewed();
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
          if (data['results'][j]['name'] == null) {
            onAirTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['name'])) {
              onAirTitle = data['results'][j]['name'];
            }
            //onAirTitle = data['results'][j]['name'];
          }
          if (data['results'][j]['overview'] == null) {
            onAirOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              onAirOverview = data['results'][j]['overview'];
            }
            //onAirOverview = data['results'][j]['overview'];
          }
          //onAirPoster = "First";
          if (data['results'][j]['poster_path'] == null) {
            onAirPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              onAirPoster = data['results'][j]['poster_path'];
            }
            //onAirPoster = data['results'][j]['poster_path'];
          }

          if (!viewedIDs.contains(data['results'][j]['id'])) {
            onAirID = data['results'][j]['id'];
          }

          //onAirID = data['results'][j]['id'];

          if (onAirTitle != '') {
            onAirTitles.add(onAirTitle);
            onAirOverviews.add(onAirOverview);
            if (onAirPoster == "assets/company_logo.png") {
              onAirPosters.add(AssetImage(onAirPoster));
            } else {
              onAirPosters.add(NetworkImage(baseURL + onAirPoster));
            }

            onAirPostersLinks.add(onAirPoster);
            onAirIDs.add(onAirID);
          }
          // onAirTitles.add(onAirTitle);
          // onAirOverviews.add(onAirOverview);
          // if (onAirPoster == "assets/company_logo.png") {
          //   onAirPosters.add(AssetImage(onAirPoster));
          // } else {
          //   onAirPosters.add(NetworkImage(baseURL + onAirPoster));
          // }

          // onAirPostersLinks.add(onAirPoster);
          // onAirIDs.add(onAirID);

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
    await getViewed();
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
          //popularTitle = data['results'][j]['name'];
          //popularOverview = data['results'][j]['overview'];

          if (data['results'][j]['name'] == null) {
            popularTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['name'])) {
              popularTitle = data['results'][j]['name'];
            }
          }

          if (data['results'][j]['overview'] == null) {
            popularOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              popularOverview = data['results'][j]['overview'];
            }
          }

          if (data['results'][j]['poster_path'] == null) {
            popularPoster = "assets/company_logo.png";
          } else {
            if (!viewedPosters.contains(data['results'][j]['poster_path'])) {
              popularPoster = data['results'][j]['poster_path'];
            }
            //popularPoster = data['results'][j]['poster_path'];
          }

          if (!viewedIDs.contains(data['results'][j]['id'])) {
            popularID = data['results'][j]['id'];
          }
          //popularID = data['results'][j]['id'];

          if (popularTitle != '') {
            popularTitles.add(popularTitle);
            popularOverviews.add(popularOverview);
            if (popularPoster == "assets/company_logo.png") {
              popularPosters.add(AssetImage(popularPoster));
            } else {
              popularPosters.add(NetworkImage(baseURL + popularPoster));
            }

            popularPostersLinks.add(popularPoster);
            popularIDs.add(popularID);
          }
          // popularTitles.add(popularTitle);
          // popularOverviews.add(popularOverview);
          // if (popularPoster == "assets/company_logo.png") {
          //   popularPosters.add(AssetImage(popularPoster));
          // } else {
          //   popularPosters.add(NetworkImage(baseURL + popularPoster));
          // }

          // popularPostersLinks.add(popularPoster);
          // popularIDs.add(popularID);

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
    await getViewed();
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
          if (data['results'][j]['name'] == null) {
            ratedTitle = '';
          } else {
            if (!viewedTitles.contains(data['results'][j]['name'])) {
              ratedTitle = data['results'][j]['name'];
            }
            //ratedTitle = data['results'][j]['name'];
          }
          if (data['results'][j]['overview'] == null) {
            ratedOverview = '';
          } else {
            if (!viewedOverviews.contains(data['results'][j]['overview'])) {
              ratedOverview = data['results'][j]['overview'];
            }
            //ratedOverview = data['results'][j]['overview'];
          }

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
            ratedIDs.add(ratedID);
            if (ratedPoster == "assets/company_logo.png") {
              ratedPosters.add(AssetImage(ratedPoster));
            } else {
              ratedPosters.add(NetworkImage(baseURL + ratedPoster));
            }

            ratedPostersLinks.add(ratedPoster);
          }
          // ratedTitles.add(ratedTitle);
          // ratedOverviews.add(ratedOverview);
          // ratedIDs.add(ratedID);
          // if (ratedPoster == "assets/company_logo.png") {
          //   ratedPosters.add(AssetImage(ratedPoster));
          // } else {
          //   ratedPosters.add(NetworkImage(baseURL + ratedPoster));
          // }

          // ratedPostersLinks.add(ratedPoster);
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
