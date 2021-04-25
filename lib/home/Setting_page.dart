
import 'package:flutter/material.dart';
import 'package:game/home/Main_page.dart';
import 'package:game/model/progress.dart';
import 'package:game/util/progress_database_helper.dart';
import 'package:game/util/quiz_data.dart';

class SettingPage extends StatefulWidget{
  @override
  SettingPageState createState() => new SettingPageState();
}

class SettingPageState extends State<SettingPage> {

  Future<Progress> fetchlanguageFromDatabase() async{
    var dbHelper = QuizData.progresshelper;
    Future<Progress> progress = dbHelper.getlanguage();
    return progress;
  }
  List<String> _languageData = ["English", "Romanian", 'Austrian'];
  List<String> _flagData = ["assets/england.png", "assets/romania.png", 'assets/austria.png'];

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: FutureBuilder<Progress>(
        future: fetchlanguageFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text("Select Language"),
                  flexibleSpace: Image(
                    image: AssetImage('assets/appbar_bg.png'),
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        iconSize: 16,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context)=> MainPage(),
                          ));
                        },
                      );
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: 3,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          if (index == snapshot.data.value){
                            selected = false;
                          }
                          else selected = true;
                          return InkWell(
                            onTap: () async {
                              updatecount(index);
                              setState(() {
                                selected = false;
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context)=> MainPage(),
                              ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: <Widget>[
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(40)),
                                          image: DecorationImage(image: AssetImage(_flagData[index]), fit: BoxFit.cover),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width:  40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(40)),
                                          color: selected? Colors.white.withOpacity(0.85):Colors.white.withOpacity(0),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: !selected ? 24 : 0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _languageData[index],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context).textTheme.subhead,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
            );
          } else if (snapshot.hasError) {
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

  void updatecount(int value){
    var dbHelper = ProgressDatabaseHelper();
    dbHelper.updatelangcount(value);
  }
}

