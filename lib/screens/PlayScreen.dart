import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../utils/databaseHelper.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

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

  Stream<DurationState> get durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          songPlayer.positionStream,
          songPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

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
    songPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        updateCurrentPlayingSongDetails(index);
      }
    });
  }

  ////////////////////////////////////////////////////////////Alert Dialog Specific

  // Media Query
  final OnAudioQuery audioQuery = OnAudioQuery();

  // Audio Player
  final AudioPlayer songPlayer = AudioPlayer();
  final AudioPlayer affirmationPlayer = AudioPlayer();
  List<SongModel> songs = [];
  List<SongModel> itemData = [];
  String currentSongTitle = '';
  int currentIndex = 0;
  bool isPlayerViewVisible = false;
  bool isPlaying = false;
  double affirmationVolume = 1.0;
  double songVolume = 0.2;
  Duration songDuration = const Duration();

  // Method to set player view visibility

  void changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  // Music Control Functions

  playAffirmations() async {
    int x = 0;
    for (x = 0; x <= setsOfTagsPath.length; x++) {
      await affirmationPlayer.setAudioSource(
        ConcatenatingAudioSource(
          useLazyPreparation: true,
          shuffleOrder: DefaultShuffleOrder(),
          children: [
            AudioSource.uri(Uri.parse(setsOfTagsPath[x])),
          ],
        ),
      );
      //await affirmationPlayer.setLoopMode(LoopMode.one);
      await affirmationPlayer.setVolume(affirmationVolume);
      await affirmationPlayer.play();
    }
    x = 0;
  }

  playSong() async {
    await songPlayer.setAudioSource(createPlaylist(itemData), initialIndex: 0);
    await songPlayer.play();
  }

  playSelectedSong() async {
    await songPlayer.setAudioSource(AudioSource.uri(Uri.parse(finalUri)));
    await songPlayer.play();
  }

  togglePlayback() {
    if (isPlaying == false) {
      //playSong();
      playSelectedSong();
      playAffirmations();
      isPlaying = true;
    } else {
      songPlayer.stop();
      affirmationPlayer.stop();
      isPlaying = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    songPlayer.dispose();
    affirmationPlayer.dispose();
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

              /// Add Songs to the song List
              itemData = item.data!;
              songs.clear();
              songs = item.data!;
              ///////////////////////////
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
                                    print('URI: $uri');

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
                          onTap: () async {
                            String? playlist = setsOfTags[index].toString();
                            finalPlaylistName = playlist;
                            //print(playlist);
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

  Future<String?> openSettings() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.deepPurple[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Center(
            child: Text(
              'Sound Mixing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xffDADAC2),
              ),
            ),
          ),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xffD8CA67),
                    inactiveTrackColor: Colors.red[100],
                    trackShape: const RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    thumbColor: const Color(0xffD8CA67),
                    overlayColor: Colors.red.withAlpha(32),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 28.0,
                    ),
                    tickMarkShape: const RoundSliderTickMarkShape(),
                    activeTickMarkColor: const Color(0xffDADAC2),
                    inactiveTickMarkColor: Colors.red[100],
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: const Color(0xffDADAC2),
                    valueIndicatorTextStyle:
                        const TextStyle(color: Color(0xffD8CA67)),
                  ),
                  child: Slider(
                    value: songVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: songVolume.toStringAsFixed(2),
                    onChanged: (double newVolume) {
                      setState(
                        () {
                          songVolume = newVolume;
                        },
                      );
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    'Adjust music volume',
                    style: TextStyle(
                        color: Colors.black54,
                        overflow: TextOverflow.fade,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                    maxLines: 3,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xffD8CA67),
                    inactiveTrackColor: Colors.red[100],
                    trackShape: const RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    thumbColor: const Color(0xffD8CA67),
                    overlayColor: Colors.red.withAlpha(32),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 28.0,
                    ),
                    tickMarkShape: const RoundSliderTickMarkShape(),
                    activeTickMarkColor: const Color(0xffDADAC2),
                    inactiveTickMarkColor: Colors.red[100],
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: const Color(0xffDADAC2),
                    valueIndicatorTextStyle:
                        const TextStyle(color: Color(0xffD8CA67)),
                  ),
                  child: Slider(
                    value: affirmationVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: affirmationVolume.toStringAsFixed(2),
                    onChanged: (double newVolume) {
                      setState(
                        () {
                          affirmationVolume = newVolume;
                        },
                      );
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    'Adjust affirmation volume',
                    style: TextStyle(
                        color: Colors.black54,
                        overflow: TextOverflow.fade,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
            ),
            height: 250,
            width: double.infinity,
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
                  openLibrary();
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
              GestureDetector(
                onTap: () {
                  openSettings();
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
              ),
            ],
          ),
          // Column(
          //   children: [
          //     GestureDetector(
          //       onTap: () async {
          //         await playAffirmations();
          //       },
          //       child: Container(
          //         height: 60,
          //         width: 100,
          //         decoration: BoxDecoration(
          //           color: const Color(0xff483553),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: const [
          //             FaIcon(
          //               FontAwesomeIcons.recordVinyl,
          //               color: Color(0xffD8CA67),
          //               size: 20,
          //             ),
          //             SizedBox(
          //               height: 7,
          //             ),
          //             Text(
          //               'Mix Affirmations',
          //               style: TextStyle(
          //                 color: Color(0xffDADAC2),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.all(30.0),
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
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black12,
                ),
                Text(
                  //'Imagine Dragons',
                  //widget.recording.toString(),
                  finalPlaylistName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                    color: Color(0xffDADAC2),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  songPlayer.loopMode == LoopMode.one
                      ? songPlayer.setLoopMode(LoopMode.all)
                      : songPlayer.setLoopMode(LoopMode.one);
                },
                // child: const FaIcon(
                //   FontAwesomeIcons.arrowsRotate,
                //   color: Color(0xffDADAC2),
                //   size: 20,
                // ),
                child: StreamBuilder<LoopMode>(
                  stream: songPlayer.loopModeStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data;
                    if (LoopMode.one == loopMode) {
                      return const FaIcon(
                        FontAwesomeIcons.retweet,
                        color: Color(0xffDADAC2),
                      );
                    }
                    return const FaIcon(
                      FontAwesomeIcons.repeat,
                      color: Color(0xffDADAC2),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('Previous Track');
                  if (songPlayer.hasPrevious) {
                    songPlayer.seekToPrevious();
                  }
                },
                child: const FaIcon(
                  FontAwesomeIcons.backward,
                  color: Color(0xffDADAC2),
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (finalSong.isEmpty || finalPlaylistName.isEmpty) {
                    print(
                        'Song is: $finalSong and Playlist is: $finalPlaylistName');
                    toast(context, 'Select song and affirmation to play!');
                  } else {
                    playRecordAnimation();
                    togglePlayback();
                  }
                  setState(() {});
                },
                child: isPlaying == false
                    ? const FaIcon(
                        FontAwesomeIcons.play,
                        color: Color(0xffDADAC2),
                        size: 50,
                      )
                    : const FaIcon(
                        FontAwesomeIcons.pause,
                        color: Color(0xffDADAC2),
                        size: 50,
                      ),
              ),
              GestureDetector(
                onTap: () {
                  print('Next Track');
                  if (songPlayer.hasNext) {
                    songPlayer.seekToNext();
                  }
                },
                child: const FaIcon(
                  FontAwesomeIcons.forward,
                  color: Color(0xffDADAC2),
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: () {
                  songPlayer.setShuffleModeEnabled(true);
                  toast(context, 'Shuffle Enabled');
                },
                child: const FaIcon(
                  FontAwesomeIcons.shuffle,
                  color: Color(0xffDADAC2),
                  size: 20,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                StreamBuilder<DurationState>(
                  stream: durationStateStream,
                  builder: (context, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.position ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;
                    return ProgressBar(
                      progress: progress,
                      total: total,
                      barHeight: 15.0,
                      baseBarColor: const Color(0xffDADAC2),
                      progressBarColor: const Color(0xffD8CA67),
                      thumbColor: const Color(0xffD8CA67),
                      timeLabelTextStyle: const TextStyle(fontSize: 1),
                      onSeek: (duration) {
                        songPlayer.seek(duration);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20.0),
                StreamBuilder<DurationState>(
                  stream: durationStateStream,
                  builder: (context, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.position ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          progress.toString().split(".")[0],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          total.toString().split(".")[0],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  void updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
