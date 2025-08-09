import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows WhatsApp + Call buttons for a given phone number.
class ContactActions extends StatelessWidget {
  /// The phone number in international format (e.g. "+1234567890").
  final String phoneNumber;

  const ContactActions({Key? key, required this.phoneNumber}) : super(key: key);

  Future<void> _launchCall() async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _launchWhatsApp() async {
    // remove any '+' or non-digits for wa.me
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$digitsOnly');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp with $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // WhatsApp button
        InkWell(
          onTap: _launchWhatsApp,
          child: Image.asset(
            'assets/images/ic_whatsapp.png',
            width: 50,
            height: 50,
          ),
        ),

        const SizedBox(width: 16),

        // Call button
        InkWell(
          onTap: _launchCall,
          child: Image.asset(
            'assets/images/ic_call.png',
            width: 50,
            height: 50,
          ),
        ),
      ],
    );
  }
}
