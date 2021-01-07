import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants.dart';

class VideoApp extends StatefulWidget {
  final String videoPath;
  final Function onTap;
  final String buttonTitle;

  VideoApp(
      {@required this.videoPath,
      @required this.onTap,
      @required this.buttonTitle});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  VoidCallback listener;

  @override
  void initState() {
    _controller = VideoPlayerController.asset(
      widget.videoPath,
    )..play();

    listener = () {
      setState(() {});
    };

    // Initielize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(kAppName,
            textAlign: TextAlign.center,
            style:
                kAppBarTextStyle.copyWith(fontSize: 18.0, color: Colors.black)),
        centerTitle: true,
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text('Welcome to TimeTasker!\nHere\'s how it works',
                textAlign: TextAlign.center,
                style: kTitleTextStyle.copyWith(fontSize: 22.0)),
          ),
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Center(
                    child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the VideoPlayerController has finished initialization, use
                      // the data it provides to limit the aspect ratio of the video.
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        // Use the VideoPlayer widget to display the video.
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      // If the VideoPlayerController is still initializing, show a
                      // loading spinner.
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )),
                Center(
                    child: Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 25.0,
                    ),
                    onPressed: () {
                      // Wrap the play or pause in a call to `setState`. This ensures the
                      // correct icon is shown.
                      setState(() {
                        // If the video is playing, pause it.
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          // If the video is paused, play it.
                          _controller.play();
                        }
                      });
                    },
                  ),
                ))
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          FlatButton(
            child: Text(
              widget.buttonTitle ?? '',
              style: kSubTitleTextStyle.copyWith(
                  color: Colors.lightBlue, fontSize: 18.0),
            ),
            textColor: Colors.lightBlue,
            onPressed: widget.onTap,
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}
