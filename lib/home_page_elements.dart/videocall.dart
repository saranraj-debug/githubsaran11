import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final int uid;
  final String token;

  VideoCallScreen({required this.channelName, required this.uid, required this.token});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  bool _joined = false;
  int? _remoteUid; // Store the remote user's UID

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // Create and initialize Agora engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: "ed84c44b45c44dccbcb3181aae2980eb"));

    await _engine.enableVideo();
    await _engine.startPreview();

    // Join the channel with token
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: const ChannelMediaOptions(),
    );

    // Set event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _joined = true);
          print("Local user joined: ${connection.localUid}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
          print("Remote user joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
          print("Remote user left: $remoteUid");
        },
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: Stack(
        children: [
          _joined
              ? Stack(
                  children: [
                    // Display remote video if a remote user is present
                    _remoteUid != null
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: VideoCanvas(uid: _remoteUid!),
                            ),
                          )
                        : const Center(child: Text("Waiting for doctor to join...")),
                    
                    // Local user video (small preview in corner)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      width: 100,
                      height: 150,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: VideoCanvas(uid: widget.uid),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
          
          // End Call Button
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                _engine.leaveChannel();
                Navigator.pop(context);
              },
              child: const Text("End Call"),
            ),
          ),
        ],
      ),
    );
  }
}
