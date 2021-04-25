import 'package:game/util/progress_database_helper.dart';

import 'question_database_helper.dart';

class QuizData{
  static final List<String> english_table =[
    'E_movie_worldwide',
    'E_movie_kids',
    'E_tv_series',
    'E_music_worldwide',
    'E_music_trap',
    'E_book_tiles',
  ];
  static final List<String> romania_table = [
    'R_songs',
    'R_manele',
  ];
  static final List<String> austria_table = [
    'A_songs'
  ];
  static final List<String> english_name =[
    'Movie titles \n Worldwide',
    'Movie titles \n Kids',
    'TV Series \n titles',
    ' Music -\n Worldwide',
    'Music - Trap',
    'Book titles',
  ];
  static final List<String> romania_name = [
    'Romanian songs',
    'Romanian manele',
  ];
  static final List<String> austria_name = [
    'Austrian songs'
  ];
  static final List<String> english_img =[
    'assets/img/img1.jpg',
    'assets/img/img2.jpg',
    'assets/img/img3.jpg',
    'assets/img/img4.jpg',
    'assets/img/img5.jpg',
    'assets/img/img6.jpg',
  ];
  static final List<String> romania_img = [
    'assets/img/img7.jpg',
    'assets/img/img8.jpg',
  ];
  static final List<String> austria_img = [
    'assets/img/img9.jpg'
  ];
 static final progresshelper = ProgressDatabaseHelper();
 static final questionhelper = QuestionDatabaseHelper();
 static List<int> total = null;
 static List<int> current = null;
}