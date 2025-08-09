// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/constants/app_constants.dart';
// import '../../../domain/entities/report.dart';
//
// class ReportsScreen extends StatelessWidget {
//   const ReportsScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Mock data for reports
//     final currentMonth = DateTime.now().month;
//     final currentYear = DateTime.now().year;
//
//     final mockReports = [
//       MonthlyReport(
//         reportId: 'report1',
//         businessId: 'business123',
//         month: DateTime(currentYear, currentMonth, 1),
//         metrics: BusinessMetrics(
//           totalRevenue: 8250.00,
//           totalJobs: 35,
//           completedJobs: 34,
//           cancelledJobs: 1,
//           averageRating: 4.8,
//           revenueByService: {
//             'Deep Cleaning': 5400.00,
//             'House Keeping': 2850.00,
//           },
//           jobsByService: {
//             'Deep Cleaning': 12,
//             'House Keeping': 23,
//           },
//         ),
//         topCustomers: ['customer123', 'customer456', 'customer789'],
//         topAreas: ['Kuwait City', 'Salmiya', 'Hawalli'],
//       ),
//       MonthlyReport(
//         reportId: 'report2',
//         businessId: 'business123',
//         month: DateTime(currentMonth - 1 > 0 ? currentYear : currentYear - 1,
//             currentMonth - 1 > 0 ? currentMonth - 1 : 12, 1),
//         metrics: BusinessMetrics(
//           totalRevenue: 7325.00,
//           totalJobs: 32,
//           completedJobs: 31,
//           cancelledJobs: 1,
//           averageRating: 4.7,
//           revenueByService: {
//             'Deep Cleaning': 4800.00,
//             'House Keeping': 2525.00,
//           },
//           jobsByService: {
//             'Deep Cleaning': 10,
//             'House Keeping': 22,
//           },
//         ),
//         topCustomers: ['customer123', 'customer789', 'customer456'],
//         topAreas: ['Kuwait City', 'Salmiya', 'Farwaniya'],
//       ),
//       MonthlyReport(
//         reportId: 'report3',
//         businessId: 'business123',
//         month: DateTime(
//             currentMonth - 2 > 0 ? currentYear : currentYear - 1,
//             currentMonth - 2 > 0 ? currentMonth - 2 : 12 - (2 - currentMonth),
//             1),
//         metrics: BusinessMetrics(
//           totalRevenue: 6750.00,
//           totalJobs: 30,
//           completedJobs: 29,
//           cancelledJobs: 1,
//           averageRating: 4.6,
//           revenueByService: {
//             'Deep Cleaning': 4320.00,
//             'House Keeping': 2430.00,
//           },
//           jobsByService: {
//             'Deep Cleaning': 9,
//             'House Keeping': 21,
//           },
//         ),
//         topCustomers: ['customer456', 'customer123', 'customer789'],
//         topAreas: ['Kuwait City', 'Hawalli', 'Salmiya'],
//       ),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Business Reports'),
//       ),
//       body: Column(
//         children: [
//           // Overview card
//           Card(
//             margin: const EdgeInsets.all(16.0),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Business Performance',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const Divider(),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildStatColumn(
//                         context,
//                         'Revenue',
//                         '\$${NumberFormat('#,##0').format(mockReports[0].metrics.totalRevenue)}',
//                         Icons.attach_money,
//                         Colors.green,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'Jobs',
//                         mockReports[0].metrics.totalJobs.toString(),
//                         Icons.cleaning_services,
//                         Colors.blue,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'Avg. Value',
//                         '\$${(mockReports[0].metrics.totalRevenue / mockReports[0].metrics.totalJobs).toStringAsFixed(2)}',
//                         Icons.trending_up,
//                         Colors.purple,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'Completion',
//                         '${(mockReports[0].metrics.completedJobs / mockReports[0].metrics.totalJobs * 100).toStringAsFixed(1)}%',
//                         Icons.auto_graph,
//                         Colors.orange,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildStatColumn(
//                         context,
//                         'Satisfaction',
//                         '${mockReports[0].metrics.averageRating.toStringAsFixed(1)}/5',
//                         Icons.star,
//                         Colors.amber,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'Success Rate',
//                         '${((mockReports[0].metrics.totalJobs - mockReports[0].metrics.cancelledJobs) / mockReports[0].metrics.totalJobs * 100).toStringAsFixed(1)}%',
//                         Icons.check_circle,
//                         Colors.green,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'Deep Clean',
//                         mockReports[0]
//                             .metrics
//                             .jobsByService['Deep Cleaning']
//                             .toString(),
//                         Icons.cleaning_services,
//                         Colors.indigo,
//                       ),
//                       _buildStatColumn(
//                         context,
//                         'House Keep',
//                         mockReports[0]
//                             .metrics
//                             .jobsByService['House Keeping']
//                             .toString(),
//                         Icons.home,
//                         Colors.teal,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Monthly reports list
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: mockReports.length,
//               itemBuilder: (context, index) {
//                 final report = mockReports[index];
//                 final monthName = DateFormat('MMMM').format(report.month);
//
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 16.0),
//                   child: InkWell(
//                     onTap: () => context.go(
//                       '${AppConstants.monthlySummaryScreen}/${report.month}/${report.month.year}',
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 '$monthName ${report.month.year}',
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),
//                               Text(
//                                 '\$${NumberFormat('#,##0.00').format(report.metrics.totalRevenue)}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(
//                                       color:
//                                           Theme.of(context).colorScheme.primary,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${report.metrics.completedJobs} of ${report.metrics.totalJobs} jobs completed',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Average job value: \$${(report.metrics.totalRevenue / report.metrics.totalJobs).toStringAsFixed(2)}',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                               Text(
//                                 'Rating: ${report.metrics.averageRating.toStringAsFixed(1)}/5',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall
//                                     ?.copyWith(
//                                       color: report.metrics.averageRating >= 4.5
//                                           ? Colors.green
//                                           : (report.metrics.averageRating >= 4.0
//                                               ? Colors.orange
//                                               : Colors.red),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               TextButton.icon(
//                                 onPressed: () => context.go(
//                                   '${AppConstants.monthlySummaryScreen}/${report.month.month}/${report.month.year}',
//                                 ),
//                                 icon: const Icon(Icons.assessment),
//                                 label: const Text('View Details'),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatColumn(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 28),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ],
//     );
//   }
// }
