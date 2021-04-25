class Question{
  int _id;
  String _question;
  String _answer;

  Question(this._id, this._question, this._answer);

  Question.map(dynamic obj) {
    this._id = obj['id'];
    this._question = obj['question'];
    this._answer = obj['answer'];
  }
  int get id => _id;
  String get question => _question;
  String get answer => _answer;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if(_id != null) {
      map['id'] = _id;
    }
    map['question'] = _question;
    map['answer'] = _answer;

    return map;
  }

  Question.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._question = map['question'];
    this._answer = map['answer'];
  }
}