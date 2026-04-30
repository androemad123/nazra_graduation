import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final faqs = <_FaqItem>[
      _FaqItem(
        question: 'How do I submit a complaint?',
        answer:
            'Go to Home and tap Add New Complaint. Upload a photo, add the issue details, and submit.',
      ),
      _FaqItem(
        question: 'How can I track complaint progress?',
        answer:
            'Open My Complaints from your profile, then tap Details on any complaint to view status updates.',
      ),
      _FaqItem(
        question: 'Why can\'t I report delay for some complaints?',
        answer:
            'Delay reporting appears only after the required threshold based on complaint priority, and not for resolved/fixed issues.',
      ),
      _FaqItem(
        question: 'How do community requests work?',
        answer:
            'You can request to join a community. The owner reviews your request and approves or rejects it.',
      ),
      _FaqItem(
        question: 'How do notifications work?',
        answer:
            'You receive in-app notifications for important actions, such as status updates and community interactions.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.help),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: semiBoldStyle(fontSize: 18, color: ColorManager.darkBrown),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = faqs[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ColorManager.lighterGray),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      iconColor: ColorManager.brown,
                      collapsedIconColor: ColorManager.brown,
                      title: Text(
                        item.question,
                        style: semiBoldStyle(fontSize: 14, color: ColorManager.darkGray),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.answer,
                            style: regularStyle(fontSize: 13, color: ColorManager.gray),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

