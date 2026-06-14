class FinanceModuleConfig {
  const FinanceModuleConfig({
    required this.apiBaseUrl,
    this.enableReviewQueue = true,
    this.enableStatistics = true,
  });

  final String apiBaseUrl;
  final bool enableReviewQueue;
  final bool enableStatistics;
}
