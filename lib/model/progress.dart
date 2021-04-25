class Progress{
  String _content;
  int _value;

  Progress(this._content, this._value);

  Progress.map(dynamic obj) {
    this._content = obj['content'];
    this._value = obj['value'];
  }
  int get value => _value;
  String get content => _content;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['content'] = _content;
    map['value'] = _value;

    return map;
  }

  Progress.fromMap(Map<String, dynamic> map) {
    this._content = map['content'];
    this._value = map['value'];
  }
}