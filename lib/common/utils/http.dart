import 'package:dio/dio.dart';

// 网络请求
class Http {
  static final Http _httpClient = Http._internal();
  factory Http() => _httpClient;
  Http._internal();

  static late Dio _dio;
  static final String rootUrl = 'https://api.openweathermap.org';

  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: rootUrl,
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 5),
        connectTimeout: const Duration(seconds: 10),
        queryParameters: {"apikey": "mykey"},
      ),
    );
  }

  Future get(String path, Map<String, dynamic>? params) async {
    try {
      Response response = await _dio.get(path, queryParameters: params);
      print("****** http get data ******\n url=$path\n${response.statusCode}\n${response.data}");
      return response.data;
    } catch (e) {
      print("****** http get data ******\n url=$path\nerror = $e");
      return null;
    }
  }

  Future post(String path, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(path, data: data);
      print("****** http post data ******\n url=$path\n${response.statusCode}\n${response.data}");
      return response.data;
    } catch (e) {
      print("****** http post data ******\n url=$path\nerror = $e");
      return null;
    }
  }
}
