
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:game/home/Main_page.dart';
import 'package:game/model/question.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:io' show Platform;
import 'package:firebase_admob/firebase_admob.dart';
import 'package:game/util/quiz_data.dart';
import 'package:animated_dialog_box/animated_dialog_box.dart';
import 'package:social_share/social_share.dart';

import 'question_list.dart';



TextEditingController value_controller = new TextEditingController();

const testDevices = "Pixel_2_API_29:5554";
int current_error = 0;

List<String> error_data = [
  "Wrong",
  "wow, really wrong",
  "Seriously",
  "come on.."
];

class QuestionPage extends StatefulWidget{
  final String table_name;
  final int table_count;
  QuestionPage(this.table_name, this.table_count);
  @override
  QuestionPageState createState() => new QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevices != null? <String>[testDevices]: null,
    keywords: <String>['Book', 'Game'],
    nonPersonalizedAds: true,
  );

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  bool check_flag = null;
  bool hint_flag = false;
  String answer;

  var barcolor = Colors.red;

  int _coins = 0;

  RewardedVideoAd videoAd = RewardedVideoAd.instance;


  Future<Question> fetchQuestionFromDatabase() async{
    var dbHelper = QuizData.questionhelper;
    Future<Question> question = dbHelper.getQuestion(widget.table_name, null);
    return question;
  }

  @override
  void initState() {
    // TODO: implement initState
    value_controller = new TextEditingController();
    super.initState();
    FirebaseAdMob.instance.initialize(
        appId: getAppId(),
        );

    videoAd.load(
        adUnitId: getRewardBasedVideoAdUnitId(),
        targetingInfo: targetingInfo
    );

    videoAd.listener = (RewardedVideoAdEvent event ,{ String rewardType, int rewardAmount}){
      print("REWARDED VIDEO AD $event");

      if(event == RewardedVideoAdEvent.rewarded){
        setState(() {
          _coins = _coins + rewardAmount;
          if (_coins > 0){
              hint_flag = true;
          }
          print('coins' + _coins.toString() + '\n');
        });
      }
      else if (event == RewardedVideoAdEvent.closed){
        videoAd.load(adUnitId: getRewardBasedVideoAdUnitId(),
        targetingInfo: targetingInfo).catchError((e) => print('error in loadig again'));
      }
    };
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    double statusBarHeight = MediaQuery.of(context).padding.top;
    // TODO: implement build
    return WillPopScope(
      child: FutureBuilder<Question>(
        future: fetchQuestionFromDatabase(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            answer = snapshot.data.answer;
            return new Scaffold(
              key: scaffoldState,
                body: Stack(
                  alignment: FractionalOffset.bottomCenter,
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: new AssetImage("assets/Splash.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child:Padding(
                        padding: EdgeInsets.only(top: statusBarHeight + 10, left: 10),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context)=> MainPage(),
                            ));
                          },
                        ),
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 375),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: widget,
                                ),
                              ),
                              children: <Widget>[
                                getStateWidget(),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(snapshot.data.question,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30
                                  ),),
                                TextField(
                                  enabled: !hint_flag,
                                  style: TextStyle(color: Colors.white,
                                        fontSize: 30),
                                  keyboardType: TextInputType.text,
                                  controller: value_controller,
                                  textAlign: TextAlign.center,
                                  onChanged: (text){
                                      int length = answer.length;
                                      int sum = 0;
                                      if(text.toLowerCase().compareTo(answer.toLowerCase()) == 0){
                                        setState(() {
                                          hint_flag = true;
                                          barcolor = Colors.green;
                                        });
                                        return;
                                      }
                                      String input_value = text.toLowerCase();
                                      String answer_value = answer.toLowerCase();
                                      for(int i = 0; i < input_value.length; i++){
                                        if(input_value.substring(i, i + 1).compareTo(answer_value.substring(i, i + 1))==0)
                                          sum++;
                                        else break;
                                      }
                                      print("sum::" + sum.toString());
                                      if(sum > length * 2/3){
                                        setState(() {
                                          barcolor = Colors.orange;
                                        });
                                      } else if (sum > length/3){
                                        setState(() {
                                          barcolor = Colors.yellow;
                                        });
                                      } else {
                                        setState(() {
                                          barcolor = Colors.red;
                                        });
                                      }
                                  },
                                  decoration: InputDecoration(
                                    errorMaxLines: 50,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: barcolor,
                                            width: 2.0)),
                                    disabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: barcolor,
                                            width: 2.0)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: barcolor,
                                            width: 2.0)),
                                  ),
                                  obscureText: false,
                                ),
                                RaisedButton(
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                  onPressed: (){
                                    check_answer();
                                  },
                                  child: new Text("Next"),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    Positioned(
                      child:Row(
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: RaisedButton(
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                  onPressed: (){
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context)=> QuestionList(widget.table_name),
                                    ));
                                  },
                                  child: new Text("Levels"),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: RaisedButton(
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                  onPressed: () async {
                                    String message = "QUIZMOJI Game \n Hey, could you help me with this question?\n" + snapshot.data.question;
                                    if(Platform.isAndroid) {
                                      var response = await FlutterShareMe().shareToSystem(msg: message);
                                      if (response == 'success') {
                                        print('navigate success');
                                      }
                                    } else {
//                                      await FlutterShare.share(title: 'Example here');
                                      SocialShare.shareOptions(message);
                                    }
                                  },
                                  child: new Text("Share"),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: RaisedButton(
                                  key: ValueKey<String>('ShOW REWARDED VIDEO'),
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                  onPressed: () {
                                    if(hint_flag) {
                                      try {
                                        showSnackBar('You already check hint.');
                                      } catch (e, s) {
                                        print(s);
                                      }
                                      return;
                                    }
                                    checkhint();

                                  },
                                  child: new Text("Hint"),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                )
            );
          }
          else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return new Container(alignment: AlignmentDirectional.center,
            color: Colors.white,
            child: new CircularProgressIndicator(),);
        },
      ),
      onWillPop: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context)=> MainPage(),
        ));
      },
    );

  }

  Future<void> checkhint() async {
    var dbHelper = QuizData.progresshelper;
    int hintcount = await dbHelper.getcurrenthint();
      await animated_dialog_box.showScaleAlertBox(
          title: Center(child: Text('Hint')), // IF YOU WANT TO ADD
          context: context,
          firstButton: MaterialButton(
            // FIRST BUTTON IS REQUIRED
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            color: Colors.white,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context).pop();
              if(hintcount > 0) {
                var dbHelper = QuizData.progresshelper;
                await dbHelper.decreasehint();
                setState(() {
                  hint_flag = true;
                  barcolor = Colors.green;
                });
              } else {
                  await videoAd.show().catchError((e) => print("error in showing ad:${e.toString()}"));
              }
            },
          ),
          secondButton: MaterialButton(
            // OPTIONAL BUTTON
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            color: Colors.white,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          icon: Icon(Icons.help_outline,color: Colors.red,), // IF YOU WANT TO ADD ICON
          yourWidget: Container(
            child: hintcount > 0? Text('$hintcount hints left.'):
            Text('You have no hint.Please get hint.'),
          ));

  }

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    ));
  }
  Widget getStateWidget() {
    if(!hint_flag && check_flag == null){
      return SizedBox(
        height: 20,
      );
    }
    if(hint_flag){
      value_controller.text = answer;
      return SizedBox(
        height: 20,
      );
    }
    if(!check_flag) {
      return Text(
        error_data[current_error],
        style: TextStyle(
          fontSize: 20,
          color: Colors.red,
        ),
      );
    }
  }
  Future<void> showdialog() async {
    await animated_dialog_box.showScaleAlertBox(
        title: Center(child: Text('Congratulations')), // IF YOU WANT TO ADD
        context: context,
        firstButton: MaterialButton(
          // FIRST BUTTON IS REQUIRED
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: Colors.white,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        secondButton: MaterialButton(
          // FIRST BUTTON IS REQUIRED
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: Colors.white,
          child: Text('Start Over'),
          onPressed: () async {
            Navigator.of(context).pop();
            QuizData.progresshelper.init_progress(widget.table_name);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context)=> QuestionPage(widget.table_name, null),
            ));
          },
        ),
        icon: Icon(Icons.info_outline,color: Colors.red,), // IF YOU WANT TO ADD ICON
        yourWidget: Container(
          child:
          Text("You answered all questions of this categories.\n Please answer in other category.",
            textAlign: TextAlign.center,),
        ));
  }
  Future<void> check_answer() async {
    if(value_controller.text.trim().length == 0) return;
    if(value_controller.text.trim().toLowerCase().compareTo(answer.toLowerCase()) == 0) {

      AudioCache player = new AudioCache();
      const alarmAudioPath = "level_complete.wav";
      player.play(alarmAudioPath);
      
      var dbHelpers = QuizData.questionhelper;
      if(widget.table_count != null){
        int _solvednumber =await QuizData.progresshelper.getcurrentnumber(widget.table_name);
        int _totalnumber =await dbHelpers.gettotalnumber(widget.table_name);
        if(widget.table_count <_solvednumber){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context)=> QuestionPage(widget.table_name, widget.table_count + 1),
          ));
        }
        if(widget.table_count == _solvednumber){
          if(_solvednumber == _totalnumber){
            showdialog();
          }
          else{
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context)=> QuestionPage(widget.table_name, null),
            ));
          }
        }
      }

      String data = await dbHelpers.updatecount(widget.table_name);
      if (data.compareTo('successful') == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context)=> QuestionPage(widget.table_name, null),
        ));
      }
      else {
        showdialog();
      }
    } else{
      Random random = new Random();
      int randomnumber = random.nextInt(4);
      setState(() {
        check_flag = false;
        current_error = randomnumber;
      });
    }
  }
}




String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-2789022727093400~8780972293';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2789022727093400~9902482279';
  }
  return null;
}

String getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-2789022727093400/7739353360';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2789022727093400/8860863340';
  }
  return null;
}