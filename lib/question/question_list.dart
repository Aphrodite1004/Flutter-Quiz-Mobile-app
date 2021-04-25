import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:game/model/question.dart';
import 'package:game/util/question_database_helper.dart';

import 'Question_main.dart';

class QuestionList extends StatefulWidget{
  final String table_name;
  QuestionList(this.table_name);
  @override
  QuestionListState createState() => new QuestionListState();
}

class QuestionListState extends State<QuestionList>{

  Future<List<Question>> fetchlistFromDatabase() async{
    var dbHelper = QuestionDatabaseHelper();
    Future<List<Question>> progress = dbHelper.getquestionlist(widget.table_name);
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<List<Question>>(
      future: fetchlistFromDatabase(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return new Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("Question List"),
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
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              body: new Container(
                padding: new EdgeInsets.all(16.0),
                child: new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index){
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (context)=> QuestionPage(widget.table_name, index + 1),
                                ));
                              },
                              child: FadeInAnimation(
                                  child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(snapshot.data[index].question,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0
                                    ),),
                                  new Text(snapshot.data[index].answer,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0
                                    ),),
                                  new Divider()
                                ],
                              )
                              ),
                            ),
                          ));
                    }),
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
    );
  }

}