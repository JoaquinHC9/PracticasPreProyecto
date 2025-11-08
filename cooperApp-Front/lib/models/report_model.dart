class ReportModel {
  final String accountId;
  final String reason;
  final List<String> evidencePaths;

  ReportModel({
    required this.accountId,
    required this.reason,
    required this.evidencePaths,
  });
}
