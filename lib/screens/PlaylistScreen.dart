import 'package:ei_positive_affirmations/screens/PlayScreen.dart';
import 'package:ei_positive_affirmations/utils/databaseHelper.dart';
import 'package:flutter/material.dart';

class PlaylistScreen extends StatefulWidget {
  //const PlaylistScreen({Key? key}) : super(key: key);

  PlaylistScreen(
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
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  var allTags = [];
  var setsOfTags = [];
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    setState(() => dbHelper = DatabaseHelper.instance);
    //getTags();
  }

  getTags() async {
    var x = await dbHelper.fetchGroupedTags();
    allTags = x;
    setsOfTags = allTags.toSet().toList();
    print(setsOfTags);
    //print('All Tags: $allTags');
    return setsOfTags;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Playlists',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xffDADAC2),
              ),
            ),
          ),
          FutureBuilder<dynamic>(
            future: getTags(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final error = snapshot.error;
                return Text('Error ${error.toString()}');
              } else if (snapshot.hasData) {
                var data = snapshot.data!;
                //return Text('Data: $data');
                return GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: setsOfTags.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          String? playlist = setsOfTags[index].toString();
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
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
