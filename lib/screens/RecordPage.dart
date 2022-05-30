import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  SMIInput<bool>? recordButtonInput;
  Artboard? recordButtonArtboard;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE4E4E4),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeArea(
            child: Row(
              children: const [
                Icon(Icons.add),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Test',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(60.0),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFE2C9C6), Color(0xFFE9E9E9)],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(60.0),
                ),
              ),
              height: 250.0,
              child: Column(
                children: [
                  const SizedBox(height: 30.0),
                  const Center(
                    child: Text(
                      '00:00',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 50.0),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  recordButtonArtboard == null
                      ? const SizedBox()
                      : Center(
                          child: GestureDetector(
                            onTapDown: (_) => recordButtonAnimation(),
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              //child: RiveAnimation.asset('rive/record.riv'),
                              child: Rive(
                                artboard: recordButtonArtboard!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
