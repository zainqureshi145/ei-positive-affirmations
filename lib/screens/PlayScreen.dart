import 'package:ei_positive_affirmations/screens/AndroidLibraryScreen.dart';
import 'package:ei_positive_affirmations/screens/PlaylistScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/databaseHelper.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);
  // PlayScreen(
  //     {this.uri,
  //     this.title,
  //     this.playlist,
  //     this.recordingPath,
  //     this.recording});
  // final String? uri;
  // final String? title;
  // final String? playlist;
  // final String? recordingPath;
  // final String? recording;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  SMIInput<bool>? playButtonInput;
  Artboard? playButtonArtboard;

  List<String> finalPlaylist = [];
  String finalPlaylistName = '';
  String finalSong = '';
  String finalUri = '';

  // Animation Control
  void playRecordAnimation() {
    if (playButtonInput?.value == false &&
        playButtonInput?.controller.isActive == false) {
      playButtonInput?.value = true;
    } else if (playButtonInput?.value == true &&
        playButtonInput?.controller.isActive == true) {
      playButtonInput?.value = false;
    }
  }

  @override
  void initState() {
    requestStoragePermission();
    super.initState();
    setState(() => dbHelper = DatabaseHelper.instance);
    rootBundle.load('rive/vinyl_player.riv').then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var controller =
          StateMachineController.fromArtboard(artboard, 'vinyl_animation');
      if (controller != null) {
        artboard.addController(controller);
        playButtonInput = controller.findInput('isPlaying');
      }
      setState(() {
        playButtonArtboard = artboard;
      });
    });
  }

  ////////////////////////////////////////////////////////////Alert Dialog Specific

  // Media Query
  final OnAudioQuery audioQuery = OnAudioQuery();

  // Audio Player
  final AudioPlayer songPlayer = AudioPlayer();
  final AudioPlayer affirmationPlayer = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    songPlayer.dispose();
  }

  void requestStoragePermission() async {
    // Only if platform is web, because web have no permissions
    if (!kIsWeb) {
      bool permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() {});
    }
  }

  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  var allTags = [];
  var setsOfTags = [];
  var allTagsPath = [];
  var setsOfTagsPath = [];
  late DatabaseHelper dbHelper;

  getTags() async {
    var x = await dbHelper.fetchGroupedTags();
    allTags = x;
    setsOfTags = allTags.toSet().toList();
    print(setsOfTags);
    //print('All Tags: $allTags');
    return setsOfTags;
  }

  getPathOfTags(String tag) async {
    var x = await dbHelper.fetchPathOfGroupedTags(tag);
    allTagsPath = x;
    setsOfTagsPath = allTagsPath.toSet().toList();
    print('Usable List? => $setsOfTagsPath');
    return setsOfTagsPath;
  }

  /////////////////////////////////////////////////////ALERT DIALOGS

  // Show Recording Animation Dialog
  Future openLibrary() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.deepPurple[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Center(
            child: Text(
              'Select Song',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xffDADAC2),
              ),
            ),
          ),
          content: FutureBuilder<List<SongModel>>(
            future: audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true),
            builder: (context, item) {
              if (item.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (item.data!.isEmpty) {
                return const Text('No songs found on this device');
              }
              return Container(
                height: 300,
                width: 600,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          //Here
                          String? uri = item.data![index].uri;
                          String? title = item.data![index].title;
                          finalSong = title;
                          finalUri = uri!;
                          Navigator.of(context).pop();
                          setState(() {});
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => PlayScreen(
                          //       uri: uri,
                          //       title: title,
                          //     ),
                          //   ),
                          // );
                        },
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              //colors: [Color(0xFFE2C9C6), Color(0xFFE9E9E9)],
                              colors: [Color(0xffb7a8d7), Color(0xffb7a8d7)],
                            ),
                            //color: const Color(0xFFE2C9C6),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.data![index].title,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            overflow: TextOverflow.clip,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0),
                                        maxLines: 3,
                                      ),
                                      Text(
                                        item.data![index].artist.toString(),
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            overflow: TextOverflow.clip,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: () async {
                                    toast(context,
                                        'Playing ${item.data![index].title}');

                                    String? uri = item.data![index].uri;

                                    await songPlayer.setAudioSource(
                                        AudioSource.uri(Uri.parse(uri!)));
                                    await songPlayer.play();
                                  },
                                  child: const FaIcon(
                                    FontAwesomeIcons.play,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // actions: [
          //   TextButton(
          //     style: TextButton.styleFrom(primary: Colors.deepPurple),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //       setState(() {});
          //     },
          //     child: const Center(
          //       child: Text('Save'),
          //     ),
          //   ),
          // ],
        ),
      );

  // Show Recording Animation Dialog
  Future openPlaylist() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.deepPurple[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Center(
            child: Text(
              'Select Affirmations Playlist',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xffDADAC2),
              ),
            ),
          ),
          content: FutureBuilder<dynamic>(
            future: getTags(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final error = snapshot.error;
                return Text('Error ${error.toString()}');
              } else if (snapshot.hasData) {
                var data = snapshot.data!;
                //return Text('Data: $data');
                return Container(
                  height: 300,
                  width: 600,
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: setsOfTags.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            String? playlist = setsOfTags[index].toString();
                            finalPlaylistName = playlist;
                            getPathOfTags(playlist);
                            Navigator.of(context).pop();
                            setState(() {});
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PlayScreen(
                            //       playlist: playlist,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                //colors: [Color(0xFFE2C9C6), Color(0xFFE9E9E9)],
                                colors: [Color(0xffb7a8d7), Color(0xffb7a8d7)],
                              ),
                              //color: const Color(0xFFE2C9C6),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                setsOfTags[index].toString(),
                                style: const TextStyle(
                                    color: Colors.black54,
                                    overflow: TextOverflow.fade,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                                maxLines: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          // actions: [
          //   TextButton(
          //     style: TextButton.styleFrom(primary: Colors.deepPurple),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //       setState(() {});
          //     },
          //     child: const Center(
          //       child: Text('Save'),
          //     ),
          //   ),
          // ],
        ),
      );

  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xfff9f8fc),
      backgroundColor: const Color(0xffb7a8d7),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff483553), Color(0xffb39ddb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              //color: Color(0xff483553),
              //color: Color(0xff9575cd),
              //color: Color(0xffb39ddb),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
            ),
            height: 250,
            width: double.infinity,
            //child: const Center(child: Text('Hello World')),
            child: playButtonArtboard == null
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      playRecordAnimation();
                    },
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Rive(
                        artboard: playButtonArtboard!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AndroidLibraryScreen(),
                  //   ),
                  // );
                  openLibrary();
                },
                child: Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    //color: Colors.deepPurple[300],
                    color: const Color(0xff483553),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      // Icon(
                      //   Icons.music_note_outlined,
                      //   color: Colors.white,
                      // ),
                      FaIcon(
                        FontAwesomeIcons.music,
                        color: Color(0xffD8CA67),
                        size: 20,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Library',
                        style: TextStyle(
                          color: Color(0xffDADAC2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PlaylistScreen(),
                  //   ),
                  // );
                  openPlaylist();
                },
                child: Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xff483553),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      // Icon(
                      //   Icons.list_outlined,
                      //   color: Colors.white,
                      // ),
                      FaIcon(
                        FontAwesomeIcons.list,
                        color: Color(0xffD8CA67),
                        size: 20,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Playlist',
                        style: TextStyle(
                          color: Color(0xffDADAC2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: 60,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff483553),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // Icon(
                    //   Icons.settings_input_composite_outlined,
                    //   color: Colors.white,
                    // ),
                    FaIcon(
                      FontAwesomeIcons.sliders,
                      color: Color(0xffD8CA67),
                      size: 20,
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xffDADAC2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    //'Thunder',
                    //widget.title.toString(),
                    finalSong,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: Color(0xffDADAC2),
                    ),
                  ),
                ),
                //SizedBox(height: 5),
                Text(
                  //'Imagine Dragons',
                  //widget.recording.toString(),
                  finalPlaylistName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                    color: Color(0xffDADAC2),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const FaIcon(
                FontAwesomeIcons.arrowsRotate,
                color: Color(0xffDADAC2),
                size: 20,
              ),
              const FaIcon(
                FontAwesomeIcons.backward,
                color: Color(0xffDADAC2),
                size: 30,
              ),
              GestureDetector(
                onTap: () async {
                  playRecordAnimation();
                  // await songPlayer
                  //     .setAudioSource(AudioSource.uri(Uri.parse(finalUri)));
                  // await songPlayer.play();
                  for (int i = 0; i < setsOfTagsPath.length; i++) {
                    print('Now Playing =====> ${setsOfTagsPath[i]}');
                    await affirmationPlayer.setAudioSource(
                        AudioSource.uri(Uri.parse(setsOfTagsPath[i])));
                    await affirmationPlayer.play();
                  }
                },
                child: const FaIcon(
                  FontAwesomeIcons.play,
                  color: Color(0xffDADAC2),
                  size: 50,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.forward,
                color: Color(0xffDADAC2),
                size: 30,
              ),
              const FaIcon(
                FontAwesomeIcons.shuffle,
                color: Color(0xffDADAC2),
                size: 20,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 50.0),
            child: LinearPercentIndicator(
              width: MediaQuery.of(context).size.width,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 2500,
              percent: 0.8,
              barRadius: const Radius.circular(5),
              // progressColor: Colors.white,
              // backgroundColor: const Color(0xffb7b8d7),
              progressColor: const Color(0xffD8CA67),
              backgroundColor: const Color(0xffDADAC2),
            ),
          ),
        ],
      ),
    );
  }
}
