// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class MonthlySummaryScreen extends StatelessWidget {
//   final String month;
//   final String year;
//
//   const MonthlySummaryScreen({
//     Key? key,
//     required this.month,
//     required this.year,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final monthInt = int.parse(month);
//     final yearInt = int.parse(year);
//     final monthName = DateFormat('MMMM').format(DateTime(yearInt, monthInt));
//
//     // In a real app, you would fetch this from a repository
//     final report = _getMockReport(monthInt, yearInt);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$monthName $yearInt Summary'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Revenue card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Revenue',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 16),
//                     Center(
//                       child: Column(
//                         children: [
//                           Text(
//                             '\$${NumberFormat('#,##0.00').format(report.metrics.totalRevenue)}',
//                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                           Text(
//                             'Total Revenue',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Revenue by Service Type',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 16),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: report.metrics.revenueByService.length,
//                       itemBuilder: (context, index) {
//                         final entry = report.metrics.revenueByService.entries.elementAt(index);
//                         final serviceType = entry.key;
//                         final revenue = entry.value;
//                         final percentage = (revenue / report.metrics.totalRevenue) * 100;
//
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(serviceType),
//                                 Text(
//                                   '\$${NumberFormat('#,##0.00').format(revenue)}',
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             LinearProgressIndicator(
//                               value: revenue / report.metrics.totalRevenue,
//                               backgroundColor: Colors.grey[200],
//                               color: serviceType == 'Deep Cleaning' ? Colors.indigo : Colors.teal,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
//                               child: Text(
//                                 '${percentage.toStringAsFixed(1)}%',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Jobs card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Jobs',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 16),
//                     Center(
//                       child: Column(
//                         children: [
//                           Text(
//                             report.metrics.totalJobs.toString(),
//                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                           Text(
//                             'Total Jobs',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Jobs by Service Type',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 16),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: report.metrics.jobsByService.length,
//                       itemBuilder: (context, index) {
//                         final entry = report.metrics.jobsByService.entries.elementAt(index);
//                         final serviceType = entry.key;
//                         final jobCount = entry.value;
//                         final percentage = (jobCount / report.metrics.totalJobs) * 100;
//
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(serviceType),
//                                 Text(
//                                   jobCount.toString(),
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             LinearProgressIndicator(
//                               value: jobCount / report.metrics.totalJobs,
//                               backgroundColor: Colors.grey[200],
//                               color: serviceType == 'Deep Cleaning' ? Colors.indigo : Colors.teal,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
//                               child: Text(
//                                 '${percentage.toStringAsFixed(1)}%',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Metrics card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Business Metrics',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 16),
//                     _buildMetricRow(
//                       context,
//                       'Average Job Value',
//                       '\$${(report.metrics.totalRevenue / report.metrics.totalJobs).toStringAsFixed(2)}',
//                       Icons.trending_up,
//                       Colors.purple,
//                     ),
//                     const Divider(),
//                     _buildMetricRow(
//                       context,
//                       'Completion Rate',
//                       '${(report.metrics.completedJobs / report.metrics.totalJobs * 100).toStringAsFixed(1)}%',
//                       Icons.auto_graph,
//                       (report.metrics.completedJobs / report.metrics.totalJobs) >= 0.95 ? Colors.green : Colors.orange,
//                     ),
//                     const Divider(),
//                     _buildMetricRow(
//                       context,
//                       'Customer Satisfaction',
//                       '${report.metrics.averageRating.toStringAsFixed(1)}/5',
//                       Icons.star,
//                       Colors.amber,
//                     ),
//                     const Divider(),
//                     _buildMetricRow(
//                       context,
//                       'Success Rate',
//                       '${((report.metrics.totalJobs - report.metrics.cancelledJobs) / report.metrics.totalJobs * 100).toStringAsFixed(1)}%',
//                       Icons.check_circle,
//                       Colors.green,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMetricRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               label,
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//           ),
//           Text(
//             value,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to get mock data
//   MonthlyReport _getMockReport(int month, int year) {
//     // Current month report
//     if (month == DateTime.now().month && year == DateTime.now().year) {
//       return MonthlyReport(
//         reportId: 'report1',
//         businessId: 'business123',
//         month: DateTime(year, month, 1),
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
//       );
//     }
//
//     // Previous month report
//     final prevMonth = DateTime.now().month - 1 > 0 ? DateTime.now().month - 1 : 12;
//     final prevYear = DateTime.now().month - 1 > 0 ? DateTime.now().year : DateTime.now().year - 1;
//
//     if (month == prevMonth && year == prevYear) {
//       return MonthlyReport(
//         reportId: 'report2',
//         businessId: 'business123',
//         month: DateTime(year, month, 1),
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
//       );
//     }
//
//     // Default report for other months
//     return MonthlyReport(
//       reportId: 'report3',
//       businessId: 'business123',
//       month: DateTime(year, month, 1),
//       metrics: BusinessMetrics(
//         totalRevenue: 6750.00,
//         totalJobs: 30,
//         completedJobs: 29,
//         cancelledJobs: 1,
//         averageRating: 4.6,
//         revenueByService: {
//           'Deep Cleaning': 4320.00,
//           'House Keeping': 2430.00,
//         },
//         jobsByService: {
//           'Deep Cleaning': 9,
//           'House Keeping': 21,
//         },
//       ),
//       topCustomers: ['customer456', 'customer123', 'customer789'],
//       topAreas: ['Kuwait City', 'Hawalli', 'Salmiya'],
//     );
//   }
// }
