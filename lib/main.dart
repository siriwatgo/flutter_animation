import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation in Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Lottie.asset('assets/lottiefiles/polar_bear_day.json'),
        child: const MyHomePage(title: 'Animation in Flutter'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // Lottie
  late final AnimationController _controllerLottie;
  late final Future<LottieComposition> _compositionLottie;

  // Rive
  late RiveAnimationController _controllerRive;

  @override
  void initState() {
    super.initState();

    _controllerLottie = AnimationController(vsync: this);
    _compositionLottie = _loadCompositionLottie();

    _controllerRive = SimpleAnimation('idle');
  }

  // Load Composition Lottie
  Future<LottieComposition> _loadCompositionLottie() async {
    var assetData =
        await rootBundle.load('assets/lottiefiles/LottieLogo1.json');
    return await LottieComposition.fromByteData(assetData);
  }

  // Toggles between play and pause animation states
  void _togglePlay() =>
      setState(() => _controllerRive.isActive = !_controllerRive.isActive);

  /// Tracks if the animation is playing by whether controller is running
  bool get isPlaying => _controllerRive.isActive;

  @override
  void dispose() {
    _controllerLottie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Load a Lottie file from your assets
              Semantics(
                label: 'This is a Lottie',
                child: LottieBuilder.asset(
                  "assets/lottiefiles/polar_bear_day.json",
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),

              // Load a Lottie file from a remote url
              Container(
                height: 200,
                child: Lottie.network(
                  'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
                  controller: _controllerLottie,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    _controllerLottie
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),

              // Load an animation and its images from a zip file
              // Lottie.asset('assets/lottiefiles/angel.zip'),

              // Custom loading Lottie
              Container(
                height: 200,
                child: FutureBuilder<LottieComposition>(
                  future: _compositionLottie,
                  builder: (context, snapshot) {
                    var composition = snapshot.data;
                    if (composition != null) {
                      return Lottie(composition: composition);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),

              // Load a Rive file from a remote url
              Container(
                height: 200,
                child: RiveAnimation.network(
                  'https://cdn.rive.app/animations/vehicles.riv',
                  controllers: [_controllerRive],
                  // Update the play state when the widget's initialized
                  onInit: (_) => setState(() {}),
                ),
              ),

              // Load a Rive file from your assets
              // RiveAnimation.asset('assets/rivefiles/noon-nap.riv'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        tooltip: isPlaying ? 'Pause' : 'Play',
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
