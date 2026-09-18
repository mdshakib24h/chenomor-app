import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoChatScreen extends StatefulWidget {
  const VideoChatScreen({Key? key}) : super(key: key);

  @override
  _VideoChatScreenState createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    
    // এখানে ক্যামেরা প্রিভিউ অন করার কোড কাজ করবে
    // সার্ভার কানেকশন এবং ম্যাচিংয়ের সিগন্যালিং খুব শীঘ্রই সেটআপ হয়ে যাবে।
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // রিমোট ইউজারের ভিডিওর জায়গা
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  "Remote User Video",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),

          // কাউকে না পেলে লোডিং দেখাবে
          if (_isSearching)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFEC4899)),
                    SizedBox(height: 16),
                    Text(
                      "Searching for a stranger...",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // নিজের ক্যামেরা প্রিভিউ (ডান পাশের উপরে ছোট স্ক্রিন)
          Positioned(
            top: 50,
            right: 20,
            width: 100,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          ),

          // নিচে স্কিপ/নেক্সট বাটন
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // স্কিপ করার লজিক
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.skip_next, color: Colors.white),
                label: const Text(
                  "Next / Skip",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
