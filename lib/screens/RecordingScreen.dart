import 'dart:io';
import 'package:ei_positive_affirmations/utils/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:record/record.dart';
import 'package:ei_positive_affirmations/model/recording.dart';
import 'package:path_provider/path_provider.dart';
import 'PlayScreen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  SMIInput<bool>? recordButtonInput;
  Artboard? recordButtonArtboard;
  late TextEditingController nameEditingController;
  late TextEditingController tagEditingController;
  bool isRecording = false;
  List<Recording> recordings = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final record = Record();

  @override
  void initState() {
    super.initState();
    createDirectory();
    // Text Controllers
    nameEditingController = TextEditingController();
    tagEditingController = TextEditingController();

    // Database
    setState(() => dbHelper = DatabaseHelper.instance);
    refreshRecordingList();

    // Artboard Controllers
    rootBundle.load('rive/record.riv').then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'Record');
      if (controller != null) {
        artboard.addController(controller);
        recordButtonInput = controller.findInput('isRecording');
      }
      setState(() => recordButtonArtboard = artboard);
    });
  }

  @override
  void dispose() {
    nameEditingController.dispose();
    tagEditingController.dispose();
    super.dispose();
  }

  // Database
  late DatabaseHelper dbHelper;

  refreshRecordingList() async {
    List<Recording> x = await dbHelper.fetchRecordings();
    print('No. of Recordings: ${x.length}');
    setState(() => {recordings = x});
  }

  //Record Audio
  void toggleRecord() async {
    // List<Recording> getName = await dbHelper.fetchRecordings();
    // String name = getName[0].name;
    String directory = (await getApplicationDocumentsDirectory()).path;
    if (await record.hasPermission() && isRecording == false) {
      await record.start(
        //TODO: Get This Path From Database and Not From Controller
        path: "$directory/affirmations/${nameEditingController.text}.wav",
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
      isRecording = true;
    } else if (await record.isRecording() == true && isRecording == true) {
      await record.stop();
      isRecording = false;
    }
  }

  //Create Directory
  void createDirectory() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    if (await Directory("$directory/affirmations").exists() != true) {
      Directory("$directory/affirmations").createSync(recursive: true);
    } else if (await Directory("$directory/affirmations").exists() == true) {
      throw ErrorWidget.withDetails(
        message: 'Directory Already Exists',
      );
    } else {
      throw ErrorWidget.withDetails(
        message: 'Cannot Create Directory',
      );
    }
  }

// Animations
  void recordButtonAnimation() {
    if (recordButtonInput?.value == false &&
        recordButtonInput?.controller.isActive == false) {
      recordButtonInput?.value = true;
    } else if (recordButtonInput?.value == true &&
        recordButtonInput?.controller.isActive == true) {
      recordButtonInput?.value = false;
    }
  }

  // Show Affirmations Dialog
  Future<String?> openAlertDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xffE4E4E4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text(
            'Write your positive affirmation below',
            style: TextStyle(fontSize: 12.0),
          ),
          content: SizedBox(
            height: 200,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Write your affirmation:'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required';
                      } else {
                        return null;
                      }
                    },
                    controller: nameEditingController,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Add to playlist'),
                    controller: tagEditingController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(primary: Colors.deepPurple[300]),
              onPressed: () async {
                String directory =
                    (await getApplicationDocumentsDirectory()).path;
                String filePath =
                    "$directory/affirmations/${nameEditingController.text}.wav";
                await dbHelper.insertRecording(Recording(
                    name: nameEditingController.text,
                    tag: tagEditingController.text,
                    path: filePath));
                //await dbHelper.fetchTags();
                Navigator.of(context).pop();
                setState(() {
                  refreshRecordingList();
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );

  // Show Recording Animation Dialog
  Future openRecordAnimation() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: const Color(0xffE4E4E4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Center(
              child: Text(
                'Tap when ready',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            content: GestureDetector(
              onTap: () {
                recordButtonAnimation();
                toggleRecord();
              },
              child: SizedBox(
                width: 150,
                height: 150,
                child: Rive(
                  artboard: recordButtonArtboard!,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(primary: Colors.deepPurple),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Center(
                  child: Text('Save'),
                ),
              ),
            ],
          ));

  void clearText() {
    nameEditingController.clear();
    tagEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color(0xffE4E4E4),
      floatingActionButton: SizedBox(
        height: 45.0,
        width: 80.0,
        child: FloatingActionButton(
          onPressed: () async {
            clearText();
            openAlertDialog();
          },
          elevation: 5.0,
          backgroundColor: Colors.deepPurple[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // child: const Icon(
          //   Icons.add,
          //   color: Colors.white54,
          // ),
          child: const FaIcon(
            FontAwesomeIcons.plus,
            color: Color(0xffDADAC2),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff483553),
              image: DecorationImage(
                  image: AssetImage('images/rect.png'),
                  fit: BoxFit.cover,
                  opacity: 0.6),
            ),
            //color: const Color(0xff483553),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SafeArea(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Record Affirmations',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Color(0xffDADAC2),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: buildListView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(recordings.toString()),
          onDismissed: (direction) {
            setState(() {
              recordings.removeAt(index);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayScreen(),
                  ),
                );
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
                height: 90.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              recordings[index].name,
                              style: const TextStyle(
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0),
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              '# ${recordings[index].tag}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0),
                              maxLines: 3,
                            ),
                            Text(
                              'path: ${recordings[index].path}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Row(
                        children: [
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            elevation: 5.0,
                            color: Colors.deepPurple[300],
                            onPressed: () {
                              openRecordAnimation();
                            },
                            child: const Text('Record'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
