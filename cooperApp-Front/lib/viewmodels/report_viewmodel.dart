import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class ReportViewModel extends ChangeNotifier {
  String? selectedAccount; // Cambiar a nullable
  String reason = '';
  final List<File> evidences = [];
  final List<AccountModel> memberAccounts = [];
  bool isLoading = false;

  final AccountService _accountService = AccountService();

  void updateAccount(String? account) {
    selectedAccount = account;
    notifyListeners();
  }

  void updateReason(String text) {
    reason = text;
    notifyListeners();
  }

  Future<void> loadMemberAccounts() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final accounts = await _accountService.getAccountsWhereMember();
      memberAccounts
        ..clear()
        ..addAll(accounts);

      // Auto-seleccionar la primera cuenta si hay cuentas disponibles
      if (memberAccounts.isNotEmpty && selectedAccount == null) {
        selectedAccount = memberAccounts.first.cuentaId;
      }
    } catch (e) {
      print('Error al cargar cuentas: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.map((f) => File(f.path!)).toList();
      evidences
        ..clear()
        ..addAll(picked.take(3));
      notifyListeners();
    }
  }

  Future<void> submitReport() async {
    if (selectedAccount == null || selectedAccount!.isEmpty) {
      throw Exception("Debe seleccionar una cuenta");
    }

    if (reason.isEmpty) {
      throw Exception("Debe ingresar un motivo");
    }

    if (evidences.isEmpty) {
      throw Exception("Debe adjuntar al menos una evidencia");
    }

    await _accountService.reportAccount(
      cuentaId: selectedAccount!,
      motivo: reason,
      evidencias: evidences,
    );

    // Limpiar formulario después del envío exitoso
    selectedAccount = null;
    reason = '';
    evidences.clear();
    notifyListeners();
  }

  void prepareReport() {
    selectedAccount = null;
    reason = '';
    evidences.clear();
    notifyListeners();
  }
}