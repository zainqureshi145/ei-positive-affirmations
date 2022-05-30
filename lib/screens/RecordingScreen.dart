import 'package:ei_positive_affirmations/screens/PlayScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  SMIInput<bool>? recordButtonInput;
  Artboard? recordButtonArtboard;
  late TextEditingController textEditingController;
  List affirmations = [];

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

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
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
    textEditingController.dispose();
    super.dispose();
  }

  // Show Affirmations Dialog
  Future<String?> openAlertDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: const Color(0xffE4E4E4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text(
              'Write a descriptive name for your affirmation',
              style: TextStyle(fontSize: 12.0),
            ),
            content: TextField(
              cursorColor: Colors.deepPurple[300],
              //style: TextStyle(color: Colors.pink[400]),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Name you affirmation',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
              controller: textEditingController,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(primary: Colors.deepPurple[300]),
                onPressed: () {
                  Navigator.of(context).pop(textEditingController.text);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          ));

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
    textEditingController.clear();
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
            final affirmation = await openAlertDialog();
            if (affirmation == null || affirmation.isEmpty) return;
            affirmations.add(affirmation);
            print(affirmation);
            print(affirmations);
          },
          elevation: 5.0,
          backgroundColor: Colors.deepPurple[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white54,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            //colors: [Color(0xFFE2C9C6), Color(0xFFE9E9E9)],
            colors: [Color(0xffb7a8d7), Color(0xfff9f8fc)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              elevation: 5.0,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10.0),
                  ),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Text(
                      'Record Affirmations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: affirmations.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(affirmations.toString()),
                    onDismissed: (direction) {
                      setState(() {
                        affirmations.removeAt(index);
                        print(affirmations.toString());
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10.0),
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
                            height: 80.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      affirmations[index].toString(),
                                      style: const TextStyle(
                                          overflow: TextOverflow.fade,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    children: [
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
