import '../utils/imports.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Center(
            child: Text(
          "About Us",
        )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
                "Telly-Record is a tinder for movies type of application. You as the user are shown titles of movies/series which are currently playing/most popular/top rated/trending/upcoming as well as the description and poster. You can decide to like them by swiping right and they will be added to your liked movies/series. If you dislike them from what has been given to you, you can swipe left to dislike. If you do not want to swipe, you can just use the like/dislike buttons. You are also able to revisit your library of liked series/movies when you now feel like watching them or updating the library by deleting some."),
            Row(
              children: [
                Icon(MyFlutterApp.upcoming, size: 50),
                Text("Icon for upcoming movies")
              ],
            ),
            Row(
              children: [
                Icon(MyFlutterApp.trending, size: 50),
                Text("Icon for trending movies/series")
              ],
            ),
            Row(
              children: [
                Icon(MyFlutterApp.playing, size: 50),
                Text("Icon for now playing/showing movies")
              ],
            ),
            Row(
              children: [
                Icon(MyFlutterApp.popular, size: 50),
                Text("Icon for popular movies/series")
              ],
            ),
            Row(
              children: [
                Icon(MyFlutterApp.rated, size: 50),
                Text("Icon for top rated movies/series")
              ],
            ),
            Row(
              children: [
                Icon(MyFlutterApp.like, size: 50),
                Text("Icon for liked movies/series")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
