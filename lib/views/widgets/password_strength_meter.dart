import 'package:flutter/material.dart';
import 'package:katya/utils/password_strength.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final PasswordStrengthChecker checker;
  final bool showRequirements;
  final bool showStrengthBar;
  final bool showStrengthText;
  final double barHeight;
  final double spacing;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    required this.checker,
    this.showRequirements = true,
    this.showStrengthBar = true,
    this.showStrengthText = true,
    this.barHeight = 4.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final strength = checker.checkStrength(password);
    final requirements = checker.requirements;
    final strengthColor = checker.getStrengthColor(strength);
    final strengthLabel = checker.getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStrengthBar) ...[
          _buildStrengthBar(strength, strengthColor),
          SizedBox(height: spacing),
        ],
        if (showStrengthText) ...[
          _buildStrengthText(strength, strengthLabel, strengthColor, context),
          SizedBox(height: spacing),
        ],
        if (showRequirements && password.isNotEmpty) ...[
          _buildRequirementsList(requirements, password),
        ],
      ],
    );
  }

  Widget _buildStrengthBar(
    PasswordStrength strength,
    Color strengthColor,
  ) {
    final double widthFactor;
    switch (strength) {
      case PasswordStrength.tooWeak:
        widthFactor = 0.2;
      case PasswordStrength.weak:
        widthFactor = 0.4;
      case PasswordStrength.fair:
        widthFactor = 0.6;
      case PasswordStrength.good:
        widthFactor = 0.8;
      case PasswordStrength.strong:
        widthFactor = 1.0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            heightFactor: 1.0,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: BorderRadius.circular(barHeight / 2),
                boxShadow: [
                  BoxShadow(
                    color: strengthColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrengthText(
    PasswordStrength strength,
    String strengthLabel,
    Color strengthColor,
    BuildContext context,
  ) {
    return Row(
      children: [
        Text(
          'Strength: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          strengthLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRequirementsList(
    List<PasswordRequirement> requirements,
    String password,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        final isMet = req.validator(password);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isMet ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  req.description,
                  style: TextStyle(
                    color: isMet ? Colors.green : null,
                    decoration: isMet ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
