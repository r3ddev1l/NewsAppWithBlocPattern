import 'dart:async';
import 'dart:convert';
import 'package:bloc_practice1/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_practice1/models/news_info.dart';

enum NewsAction { Fetch, Delete }

class NewsBloc {
  final _stateStreamController = StreamController<List<Article>>();

  StreamSink<List<Article>> get _newsSink => _stateStreamController.sink;
  Stream<List<Article>> get newsStream => _stateStreamController.stream;

  final _eventStreamController = StreamController<NewsAction>();
  StreamSink<NewsAction> get eventSink => _eventStreamController.sink;
  Stream<NewsAction> get _eventStream => _eventStreamController.stream;

  NewsBloc() {
    _eventStream.listen((event) async {
      if (event == NewsAction.Fetch) {
        try {
          var newsList = await getNews();
          if (newsList != null) {
            _newsSink.add(newsList.articles);
          } else {
            _newsSink.addError('Something went wrong');
          }
        } on Exception catch (e) {
          _newsSink.addError('Something went wrong');
        }
      } else if (event == NewsAction.Delete) {}
    });
  }

  Future<NewsModel> getNews() async {
    var client = http.Client();
    var newsModel;

    try {
      var response = await client.get(Strings.news_url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);

        newsModel = NewsModel.fromJson(jsonMap);
      }
    } catch (Exception) {
      return newsModel;
    }

    return newsModel;
  }

  dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}
