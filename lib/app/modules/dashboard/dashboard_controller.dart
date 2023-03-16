import 'package:get/get.dart';
import 'package:pennywise_app/app/global/user_controller.dart';
import 'package:pennywise_app/app/models/transaction_history_data.dart';
import 'package:pennywise_app/app/services/dio_requests.dart';

class DashboardController extends GetxController {
  var transactionsList = <Transactions>[].obs;
  var userController = Get.put(UserController());

  @override
  void onInit() {
    userController.getUserData();
    getTransaction();

    super.onInit();
  }

  void getTransaction() {
    DioRequest.getTransactions(3).then((value) {
      transactionsList.value = value;
    });
  }
}
