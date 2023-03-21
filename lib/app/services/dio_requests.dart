import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pennywise_app/app/models/login_data.dart';
import 'package:pennywise_app/app/models/register_data.dart';
import 'package:pennywise_app/app/models/register_validate_data.dart';
import 'package:pennywise_app/app/models/transaction_history_data.dart';
import 'package:pennywise_app/app/models/transfer_data.dart';
import 'package:pennywise_app/app/models/user_data.dart';
import 'package:pennywise_app/app/modules/send_money/sendmoney_controller.dart';

class DioRequest {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://4cc3-110-93-82-74.ap.ngrok.io/api',
    ),
  );

  static Future registerValidate(RegisterValidate data) async {
    try {
      var response = await _dio.post(
        '/auth/register/validate',
        data: data.toJson(),
      );

      if (response.statusCode == 200) {
        return null;
      }
    } on DioError catch (e) {
      var errorResponse = e.response!.data['errors'];
      return errorResponse;
    }
  }

  static Future register(RegisterData data) async {
    try {
      var response = await _dio.post(
        '/auth/register',
        data: data.toJson(),
      );

      if (response.statusCode == 201) {
        print('SUCCESSFULLY REGISTERED');
        return null;
      }
    } on DioError catch (e) {
      var errorResponse = e.response!.statusCode;
      return errorResponse;
    }
  }

  static Future login(LoginData data) async {
    try {
      var response = await _dio.post(
        '/auth/login',
        data: data.toJson(),
      );

      if (response.statusCode == 200) {
        print('LOGGED IN');
        UserData userData = UserData.fromJson(response.data['user']);
        print(response.data['access_token']);
        saveAccessToken(response.data['access_token']);
        return userData;
      }
      return null;
    } on DioError catch (e) {
      print(e);
      return null;
    }
  }

  static Future logout() async {
    try {
      String token = getAccessToken();
      var response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print('LOGGED OUT');
        return true;
      }
      return false;
    } on DioError catch (e) {
      print(e);
      return false;
    }
  }

  // ACCESS TOKEN SAVE, GET, DELETE
  static void saveAccessToken(String accessToken) {
    final getStorage = GetStorage();
    getStorage.remove('access_token');
    getStorage.write('access_token', accessToken);
  }

  static String getAccessToken() {
    return GetStorage().read('access_token');
  }

  static void deleteAccessToken() {
    GetStorage().remove('access_token');
  }

  static Future transfer(int? userId, TransferData data) async {
    try {
      var response = await _dio.post(
        '/user/transfer',
        queryParameters: {'user': userId},
        data: data.toJson(),
      );

      if (response.statusCode == 201) {
        print('TRANSFER SUCCESS');
        return true;
      }
    } on DioError catch (e) {
      if (e.response!.statusCode == 403) {
        print('YOU ARE NOT VERIFIED');
      } else if (e.response!.statusCode == 401) {
        print('NOT ENOUGH BALANCE');
      } else {
        print(e.response);
      }
      return false;
    }
  }

  static Future<bool> cashIn(int? userId, int amount) async {
    try {
      var response = await _dio.put(
        '/user/dashboard/cashin',
        queryParameters: {'user': userId},
        data: {'amount': amount},
        // options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        print('CASH IN SUCCESS');
        return true;
      }
      return false;
    } on DioError catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<Transactions>> getTransactions(int? userId) async {
    try {
      var response = await _dio.get(
        '/user/dashboard',
        queryParameters: {'user': userId},
      );

      if (response.statusCode == 200) {
        TransactionHistoryData transactionData =
            TransactionHistoryData.fromJson(response.data);
        return transactionData.transactions!;
      }
    } on DioError catch (e) {
      if (e.response!.statusCode == 403) {
        print('YOU ARE NOT VERIFIED');
      } else if (e.response!.statusCode == 401) {
        print('NOT ENOUGH BALANCE');
      } else {
        print(e.response);
      }
      return [];
    }
    return [];
  }

  static Future<bool> getReceiver(int? userId, int receiver) async {
    var sendMoneyController = Get.put(SendMoneyController());
    try {
      var response = await _dio.get(
        '/user/transfer/receiver',
        queryParameters: {'user': userId, 'receiver': receiver},
      );

      if (response.statusCode == 200) {
        print('RECEIVER EXISTS');
        var responseData = response.data['receiver'];

        sendMoneyController.receiverData = UserData.fromJson(responseData);
        return true;
      }
      return false;
    } on DioError {
      print('NUMBER IS NOT REGISTERED');
      return false;
    }
  }

  static Future getConnections(int? userId) async {
    try {
      var response = await _dio.get(
        '/user/dashboard/connections',
        queryParameters: {'user': userId},
      );

      if (response.statusCode == 200) {
        print('CONNECTIONS');
        var connectionsJson = response.data['connections'];
        // print(connectionsJson.length);
        return connectionsJson;
      }
    } on DioError catch (e) {
      print(e);
      return null;
    }
  }
}
