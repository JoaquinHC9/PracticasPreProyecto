import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  List<AccountModel> ownerAccounts = [];
  List<AccountModel> memberAccounts = [];

  bool isLoading = true;

  HomeViewModel() {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    isLoading = true;
    notifyListeners();

    try {
      ownerAccounts = await _accountService.getAccountsWhereOwner();
      memberAccounts = await _accountService.getAccountsWhereMember();
    } catch (e) {
      print('Error al cargar cuentas: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
