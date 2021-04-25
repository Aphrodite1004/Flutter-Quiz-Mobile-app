import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:game/model/progress.dart';
import 'package:game/question/Question_main.dart';
import 'package:game/util/quiz_data.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'Setting_page.dart';



TextEditingController value_controller = new TextEditingController();

class MainPage extends StatefulWidget{
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {

  int count_category = 0;
  List<String> name_category = null;
  List<String> name_table = null;
  List<String> name_img = null;

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  Future<Progress> fetchlanguageFromDatabase() async{
    var dbHelper = QuizData.progresshelper;
    Future<Progress> progress = dbHelper.getlanguages();
    return progress;
  }

  @override
  Widget build(BuildContext context) {

    double statusBarHeight = MediaQuery.of(context).padding.top;
    // TODO: implement build
    return FutureBuilder<Progress>(
      future: fetchlanguageFromDatabase(),
      builder: (context, snapshot){
        if (snapshot.hasData){
          switch(snapshot.data.value){
            case 0:
              count_category = 6;
              name_category = QuizData.english_name;
              name_table = QuizData.english_table;
              name_img = QuizData.english_img;
              break;
            case 1:
              count_category = 2;
              name_category = QuizData.romania_name;
              name_table = QuizData.romania_table;
              name_img = QuizData.romania_img;
              break;
            case 2:
              count_category = 1;
              name_category = QuizData.austria_name;
              name_table = QuizData.austria_table;
              name_img = QuizData.austria_img;
              break;
          }
          return new Scaffold(
            key: scaffoldState,
              drawer:Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Quiz App',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                    ),
                    ListTile(
                      title: Container(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("About the app"),
                              ],
                            ),
                          )),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black12,
                      height: 1.0,
                    ),
                    ListTile(
                      title: Container(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Contact us"),
                              ],
                            ),
                          )),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black12,
                      height: 1.0,
                    ),
                  ],
                ),
              ) ,
              body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage("assets/Splash.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  alignment: FractionalOffset.topCenter,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: statusBarHeight),
                      child: Container(
                        height: 60,
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.dehaze),
                                color: Colors.white,
                                onPressed: () {
                                  scaffoldState.currentState.openDrawer();
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Quiz App',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.language),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context)=> SettingPage(),
                                  ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60 + statusBarHeight),
                      child: AnimationLimiter(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 10,
                          mainAxisSpacing:  10,
                          children: List.generate(
                            count_category,
                                (int index) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: YourListChild(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
          );
        } else if(snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return new Container(alignment: AlignmentDirectional.center,
          color: Colors.white,
          child: new CircularProgressIndicator(),);
      },
    );
  }
  Widget YourListChild(int index) {
    double percent = 0;
    percent = QuizData.current[index].toDouble() / QuizData.total[index].toDouble() * 100;
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context)=> QuestionPage(name_table.elementAt(index), null),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child:Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  QuizData.total[index].toString() + ' levels',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  name_category.elementAt(index),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Positioned(
              child: new LinearPercentIndicator(
                lineHeight: 14.0,
                percent: percent.toInt()/100,
                center: Text(
                  "${percent.toInt()}%",
                  style: new TextStyle(fontSize: 12.0),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                backgroundColor: Colors.white,
                progressColor: Colors.blue,
              ),
            ),

          ],
        ),
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          image: DecorationImage(image: AssetImage(name_img[index]), fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4.0,
              offset: const Offset(0.0, 4.0),
            ),
          ],
        ),
      ),
    );
  }
}

