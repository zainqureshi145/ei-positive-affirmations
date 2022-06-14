import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AndroidLibraryScreen extends StatefulWidget {
  const AndroidLibraryScreen({Key? key}) : super(key: key);

  @override
  State<AndroidLibraryScreen> createState() => _AndroidLibraryScreenState();
}

class _AndroidLibraryScreenState extends State<AndroidLibraryScreen> {
  // Media

  final OnAudioQuery audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<SongModel>>(
        future: audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true),
        builder: (context, item) {
          if (item.data == null) {
            return const CircularProgressIndicator();
          }
          if (item.data!.isEmpty) {
            return const Text('No songs found on this device');
          }
          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(item.data![index].title),
                subtitle: Text(item.data![index].displayName),
                trailing: const FaIcon(FontAwesomeIcons.play),
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
