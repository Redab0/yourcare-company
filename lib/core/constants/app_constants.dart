class AppConstants {
  static const String appName = 'YourCare Partner';
  static const String splashScreen = '/';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String homeScreen = '/home';

  // Nested routes under home
  // Original driver routes (kept for backward compatibility)
  static const String upcomingJobsScreen = '/home/upcoming-jobs';
  static const String completedJobsScreen = '/home/completed-jobs';
  static const String crewListScreen = '/home/staff-list';
  static const String jobDetailsScreen = '/home/job-details';

  // New business routes
  static const String cleaningRequestsScreen = 'requests';
  static const String requestDetailsScreen = '/home/request-details';
  static const String submitQuoteScreen = '/home/submit-quote';
  static const String reportsScreen = '/home/reports';
  static const String monthlySummaryScreen = '/home/monthly-summary';
  static const String businessProfileScreen = '/home/business-profile';
  static const String staffManagementScreen = '/home/staff-management';

  // API Base URL
  static const String apiBaseUrl = 'https://api.kwclean.com';

  // User roles
  static const String roleOwner = 'owner';
  static const String roleManager = 'manager';
  static const String roleWorker = 'worker';
}
