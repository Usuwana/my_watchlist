import 'dart:convert';

import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:http/http.dart';
import 'package:readmore/readmore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../screens/SomethingWentWrong.dart';
import '../../utils/imports.dart';

class LikedSeries extends StatefulWidget {
  const LikedSeries({Key? key}) : super(key: key);

  @override
  _LikedSeriesState createState() => _LikedSeriesState();
}

class _LikedSeriesState extends State<LikedSeries> {
  APIseries api = new APIseries();
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

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
            future: api.getLiked(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: api.likedTitles.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: ObjectKey(api.likedTitles[index]),
                        background: stackBehindDismiss(),
                        onDismissed: (direction) {
                          var item = api.likedTitles.elementAt(index);

                          api.removeLiked(api.likedTitles[index]);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Series deleted!"),
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  height: 100,
                                                  width: 100,
                                                  child: Image.network(
                                                    api.baseURL +
                                                        api.likedPosters[index],
                                                    fit: BoxFit.fill,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              Colors.blueGrey,
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  splashColor: Colors.blue,
                                                  icon: Image.asset(
                                                    'assets/youtube.png',
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  onPressed: () {
                                                    _getMovieTrailer(
                                                        api.likedIDs[index]);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Center(
                                                            child: SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                    Future.delayed(
                                                        Duration(seconds: 4),
                                                        () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                      if (trailerYouTubeID ==
                                                          '') {
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Movie trailer not available'),
                                                          backgroundColor:
                                                              Colors.black,
                                                        );
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                snackBar);
                                                        _showTrailer == false;
                                                      } else {
                                                        showMovieTrailerDialog(
                                                            context);
                                                        _showTrailer == false;
                                                        trailerYouTubeID == '';
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    child: Text(
                                                      api.likedTitles[index]
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.getFont(
                                                                  'Montserrat')
                                                              .copyWith(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: ReadMoreText(
                                                      api.likedOverviews[index]
                                                          .toString(),
                                                      trimLines: 5,
                                                      colorClickableText:
                                                          Colors.pink,
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          '...Show more',
                                                      trimExpandedText:
                                                          ' show less',
                                                      style:
                                                          GoogleFonts.getFont(
                                                                  'Montserrat')
                                                              .copyWith(
                                                        fontSize: 11,
                                                        color: Colors.black,
                                                      )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                print('${snapshot.error}');
                return Center(child: SomethingWentWrong());
              }
              return ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ProfileShimmer(
                      hasBottomLines: true,
                    );
                  });
            }),
      ),
    );
  }
}
