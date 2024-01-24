import '../../presentation/flutter_app_icons.dart';
import '../../screens/SomethingWentWrong.dart';
import '../../utils/imports.dart';
//import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:readmore/readmore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tinder_swipe/flutter_tinder_swipe.dart';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_video_player/potrait_player.dart';

class TopRated extends StatefulWidget {
  const TopRated({Key? key}) : super(key: key);

  @override
  _TopRatedState createState() => _TopRatedState();
}

class _TopRatedState extends State<TopRated> {
  APImovies api = new APImovies();
  late YoutubePlayerController _controller;
  List<dynamic> trailerValues = [];
  late String trailerYouTubeID = '';
  bool _showTrailer = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getMovieTrailer(int id) async {
    // this url hits the TMDb videos endpoint based on the supplied movieID (the current movie whose videos we want to fetch)
    final response = await get(Uri.parse(
        'http://api.themoviedb.org/3/movie/${id}/videos?api_key=01654b20e22c2a6a6d22085d00bd3373'));
    //final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      trailerValues = data.values.toList()[1];
      for (var trailer in trailerValues) {
        // since there are so many types of videos, we just want to get the key to the official trailer
        if (trailer['name'].contains('Official Trailer') ||
            trailer['type'].contains('Trailer')) {
          setState(() {
            // set the trailer ID fetched from the video object
            trailerYouTubeID = trailer['key'];
          });
          break;
        }
      }
    } else {
      throw Exception('Failed to load movie videos.');
    }
  }

  void showMovieTrailerDialog(BuildContext context) {
    _controller = YoutubePlayerController(
      initialVideoId: trailerYouTubeID,
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
    CardController controller = CardController();
    return Scaffold(
        body: FutureBuilder(
            future: api.getTopRated(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                api.getLiked();
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: new SwipeCard(
                          allowVerticalMovement: false,
                          stackNum: 3,
                          totalNum: api.top_rated.length,
                          swipeEdge: 4.0,
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height,
                          minWidth: MediaQuery.of(context).size.width * 0.9,
                          minHeight: MediaQuery.of(context).size.height * 0.9,
                          cardBuilder: (context, index) => Card(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  child: FadeInImage(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    fit: BoxFit.fill,
                                    placeholder:
                                        AssetImage("assets/company_logo.png"),
                                    image: api.ratedPosters[index],
                                  ),
                                ),
                                Positioned(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  bottom: 80,
                                  child: Center(
                                    child: Container(
                                        alignment: Alignment.bottomCenter,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: SingleChildScrollView(
                                          child: Center(
                                            child: ReadMoreText(
                                              api.ratedOverviews[index],
                                              trimLines: 1,
                                              colorClickableText: Colors.pink,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: '...Show more',
                                              trimExpandedText: ' show less',
                                              textAlign: TextAlign.justify,
                                              style: GoogleFonts.getFont(
                                                      'Montserrat')
                                                  .copyWith(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      backgroundColor: Colors
                                                          .blueGrey
                                                          .withOpacity(0.3)),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll<Color>(
                                                  Colors.grey
                                                      .withOpacity(0.5))),
                                      onPressed: () async {
                                        _getMovieTrailer(api.ratedIDs[index]);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            });
                                        Future.delayed(Duration(seconds: 4),
                                            () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          if (trailerYouTubeID == '') {
                                            const snackBar = SnackBar(
                                              content: Text(
                                                  'Movie trailer not available'),
                                              backgroundColor: Colors.black,
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                            _showTrailer == false;
                                          } else {
                                            showMovieTrailerDialog(context);
                                            _showTrailer == false;
                                            trailerYouTubeID == '';
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text("WATCH TRAILER",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Image.asset('assets/youtube.png',
                                              width: 20, height: 20)
                                        ],
                                      )),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red,
                                                      width: 3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: IconButton(
                                                  color: Colors.red,
                                                  iconSize: 50,
                                                  onPressed: () {
                                                    controller.swipeLeft();
                                                  },
                                                  icon:
                                                      Icon(FlutterApp.dislike)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.green,
                                                      width: 3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: IconButton(
                                                  color: Colors.green,
                                                  iconSize: 50,
                                                  onPressed: () {
                                                    controller.swipeRight();
                                                  },
                                                  icon: Icon(FlutterApp.like)),
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                          cardController: controller = CardController(),
                          swipeUpdateCallback:
                              (DragUpdateDetails details, Alignment align) {
                            if (align.x < 0) {
                            } else if (align.x > 0) {}
                          },
                          swipeCompleteCallback:
                              (CardSwipeOrientation orientation, int index) {
                            switch (orientation) {
                              case CardSwipeOrientation.LEFT:
                                print("YESSIR");
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Center(
                                    child: Text('DISLIKED!',
                                        style: GoogleFonts.getFont('Montserrat')
                                            .copyWith(
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red)),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  duration: Duration(milliseconds: 100),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ));

                                break;
                              case CardSwipeOrientation.RIGHT:
                                if (api.likedTitles
                                    .contains(api.ratedTitles[index])) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Center(
                                      child: Text('ALREADY LIKED!',
                                          style:
                                              GoogleFonts.getFont('Montserrat')
                                                  .copyWith(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red)),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    duration: Duration(milliseconds: 100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ));
                                } else {
                                  api.addLiked(
                                      api.ratedPostersLink[index],
                                      api.ratedTitles[index],
                                      api.ratedOverviews[index],
                                      api.ratedIDs[index]);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Center(
                                      child: Text('LIKED!',
                                          style:
                                              GoogleFonts.getFont('Montserrat')
                                                  .copyWith(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green)),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    duration: Duration(milliseconds: 100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ));
                                }
                                break;
                              case CardSwipeOrientation.RECOVER:
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                print('${snapshot.error}');
                return Center(child: SomethingWentWrong());
              }
              return Center(
                child: Container(
                  child: LoadingAnimationWidget.inkDrop(
                      color: Colors.green, size: 100),
                ),
              );
            }));
  }
}
