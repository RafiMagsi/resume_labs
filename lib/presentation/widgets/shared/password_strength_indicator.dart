import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final requirements = _getRequirements();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: strength.value,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    strength.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strength.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: requirements.map((req) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    req.met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: req.met
                        ? AppColors.passwordStrong
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    req.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: req.met
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  _Strength _calculateStrength() {
    if (password.isEmpty) {
      return _Strength(0, 'None', AppColors.textTertiary);
    }

    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) {
      return _Strength(0.25, 'Weak', AppColors.passwordWeak);
    } else if (score <= 4) {
      return _Strength(0.5, 'Fair', AppColors.passwordFair);
    } else if (score <= 5) {
      return _Strength(0.75, 'Good', AppColors.passwordGood);
    } else {
      return _Strength(1.0, 'Strong', AppColors.passwordStrong);
    }
  }

  List<_Requirement> _getRequirements() {
    return [
      _Requirement(
        'At least 8 characters',
        password.length >= 8,
      ),
      _Requirement(
        'Contains uppercase letter',
        password.contains(RegExp(r'[A-Z]')),
      ),
      _Requirement(
        'Contains lowercase letter',
        password.contains(RegExp(r'[a-z]')),
      ),
      _Requirement(
        'Contains number',
        password.contains(RegExp(r'[0-9]')),
      ),
    ];
  }
}

class _Strength {
  final double value;
  final String label;
  final Color color;

  _Strength(this.value, this.label, this.color);
}

class _Requirement {
  final String label;
  final bool met;

  _Requirement(this.label, this.met);
}
