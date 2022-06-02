import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blur/blur.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  SMIInput<bool>? playButtonInput;
  Artboard? playButtonArtboard;
  String dropdownValue = 'One';

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
    super.initState();
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
              Container(
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
              children: const [
                Text(
                  'Thunder',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                    color: Color(0xffDADAC2),
                  ),
                ),
                //SizedBox(height: 5),
                Text(
                  'Imagine Dragons',
                  style: TextStyle(
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
            children: const [
              FaIcon(
                FontAwesomeIcons.arrowsRotate,
                color: Color(0xffDADAC2),
                size: 20,
              ),
              FaIcon(
                FontAwesomeIcons.backward,
                color: Color(0xffDADAC2),
                size: 30,
              ),
              FaIcon(
                FontAwesomeIcons.play,
                color: Color(0xffDADAC2),
                size: 50,
              ),
              FaIcon(
                FontAwesomeIcons.forward,
                color: Color(0xffDADAC2),
                size: 30,
              ),
              FaIcon(
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
