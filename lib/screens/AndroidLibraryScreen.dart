import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:just_audio/just_audio.dart';

import 'PlayScreen.dart';

class AndroidLibraryScreen extends StatefulWidget {
  //const AndroidLibraryScreen({Key? key}) : super(key: key);

  AndroidLibraryScreen(
      {this.uri,
      this.title,
      this.playlist,
      this.recordingPath,
      this.recording});
  final String? uri;
  final String? title;
  final String? playlist;
  final String? recordingPath;
  final String? recording;

  @override
  State<AndroidLibraryScreen> createState() => _AndroidLibraryScreenState();
}

class _AndroidLibraryScreenState extends State<AndroidLibraryScreen> {
  // Media Query
  final OnAudioQuery audioQuery = OnAudioQuery();

  // Audio Player
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Music Library',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xffDADAC2),
              ),
            ),
          ),
          FutureBuilder<List<SongModel>>(
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
              return Expanded(
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

                                    await player.setAudioSource(
                                        AudioSource.uri(Uri.parse(uri!)));
                                    await player.play();
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
        ],
      ),
    );
  }
}
