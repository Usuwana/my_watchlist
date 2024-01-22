import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../presentation/flutter_app_icons.dart';
import '../../screens/SomethingWentWrong.dart';
import '../../utils/imports.dart';
//import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:readmore/readmore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tinder_swipe/flutter_tinder_swipe.dart';

class Trailers extends StatefulWidget {
  const Trailers({Key? key}) : super(key: key);

  @override
  _TrailerState createState() => _TrailerState();
}

class _TrailerState extends State<Trailers> {
  APImovies api = new APImovies();
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  void showMovieTrailerDialog(BuildContext context, String id) {
    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          content: YoutubePlayer(
            // content of the alert dialog is our YT video
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () => debugPrint('Ready'), // for debugging purposes only
            bottomActions: [
              CurrentPosition(),
              ProgressBar(
                isExpanded: true,
                colors: const ProgressBarColors(
                  playedColor: Colors.orange,
                  handleColor: Colors.orangeAccent,
                ),
              ),
              const PlaybackSpeedButton(),
              FullScreenButton(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: api.getTrailer(572802),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              showMovieTrailerDialog(context, api.trailer);
            } else if (snapshot.hasError) {
              const snackBar = SnackBar(
                content: Text('Movie trailer not available'),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            return Center(
              child: Container(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.green, size: 100),
              ),
            );
          }),
    );
  }
}
