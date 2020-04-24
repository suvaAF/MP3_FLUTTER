import 'dart:async';
import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Souva MP3 Flutter',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(title:'Souva MP3 Music',),
    );
  }

}

class Home extends StatefulWidget {

  Home({Key key, this.title}) : super(key : key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _Home();
  }

}

class _Home extends State<Home> {

  List<Musique> maListeDeMusique = [
    new Musique('THEME DBZ', 'Bejita', 'image/bejita.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('THEME DBZ', 'Goku', 'image/goku.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerStata statut = PlayerStata.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: new Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 3,
                child: new Image.asset(maMusiqueActuelle.imagePath),
            ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((statut == PlayerStata.playing) ?Icons.pause: Icons.play_arrow, 45.0, (statut == PlayerStata.playing) ?ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree),0.8)
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    audioPlayer.seek(d);
                  });
                })
          ],
            ),
        ),
      );

  }
    IconButton bouton(IconData icone, double taille, ActionMusic action) {
      return new IconButton(
        iconSize: taille,
          color: Colors.white,
          icon: new Icon (icone),
          onPressed: () {
            switch (action) {
              case ActionMusic.play:
                play();
                break;
              case ActionMusic.pause:
                pause();
                break;
              case ActionMusic.rewind:
                rewind();
                break;
              case ActionMusic.forward:
                forward();
                break;
            }
          }
      );
    }

    Text texteAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
    }

    void configurationAudioPlayer() {
      audioPlayer = new AudioPlayer();
      positionSub = audioPlayer.onAudioPositionChanged.listen(
          (pos) => setState(() => position = pos)
      );
      stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == AudioPlayerState.PLAYING) {
          setState(() {
              duree = audioPlayer.duration;
          });
        } else if (state == AudioPlayerState.STOPPED) {
          setState(() {
            statut = PlayerStata.stopped;
          });
         }
        }, onError: (message) {
          print('erreur: $message');
          setState(() {
            statut = PlayerStata.stopped;
            duree = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        }
        );
      }

      Future play() async {
        await audioPlayer.play(maMusiqueActuelle.urlSong);
        setState(() {
          statut = PlayerStata.playing;
        });
      }

      Future pause() async {
        await audioPlayer.pause();
        setState(() {
          statut = PlayerStata.paused;
        });
      }

      void forward() {
        if (index == maListeDeMusique.length - 1) {
          index = 0;
        } else {
          index++;
        }
        maMusiqueActuelle = maListeDeMusique[index];
        audioPlayer.stop();
        configurationAudioPlayer();
        play();
        }

        String fromDuration(Duration duree) {
          print(duree);
          return duree.toString().split('.').first;
        }

      void rewind() {
        if(position > Duration(seconds: 3)) {
          audioPlayer.seek(0.0);
        } else {
          if (index == 0) {
            index = maListeDeMusique.length - 1;
          } else {
            index--;
          }
          maMusiqueActuelle = maListeDeMusique[index];
          audioPlayer.stop();
          configurationAudioPlayer();
          play();
        }
      }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerStata {
  playing,
  stopped,
  paused
}



