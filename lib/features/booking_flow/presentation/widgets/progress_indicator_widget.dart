import 'package:flutter/material.dart';

/// Progress indicator showing current step in booking flow
class BookingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTap;

  const BookingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.onStepTap,
  });

  static const List<String> stepLabels = [
    'Select Child',
    'Trip Type',
    'Direction',
    'Locations',
    'Schedule',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicators with connecting lines
          Row(
            children: List.generate(6, (index) {
              final stepNum = index + 1;
              final isCompleted = currentStep > stepNum;
              final isCurrent = currentStep == stepNum;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // Step circle
                          GestureDetector(
                            onTap: () => onStepTap(stepNum),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.green.shade500
                                    : isCurrent
                                    ? Colors.indigo.shade600
                                    : Colors.grey.shade200,
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: Colors.indigo.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Text(
                                        '$stepNum',
                                        style: TextStyle(
                                          color: isCurrent
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Step label
                          Text(
                            stepLabels[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? Colors.indigo.shade600
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Connecting line (except for last step)
                    if (index < 5)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 32),
                          color: currentStep > stepNum
                              ? Colors.green.shade500
                              : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
