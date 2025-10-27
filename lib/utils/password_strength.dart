import 'package:zxcvbn/zxcvbn.dart';

enum PasswordStrength {
  tooWeak,
  weak,
  fair,
  good,
  strong,
}

class PasswordRequirement {
  final String description;
  final bool Function(String) validator;
  final String errorMessage;

  const PasswordRequirement({
    required this.description,
    required this.validator,
    required this.errorMessage,
  });
}

class PasswordStrengthChecker {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final bool checkCommonPasswords;
  final List<String> additionalCommonPasswords;

  const PasswordStrengthChecker({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
    this.checkCommonPasswords = true,
    this.additionalCommonPasswords = const [],
  });

  List<PasswordRequirement> get requirements {
    final requirements = <PasswordRequirement>[];

    requirements.add(
      PasswordRequirement(
        description: 'At least $minLength characters',
        validator: (password) => password.length >= minLength,
        errorMessage: 'Password must be at least $minLength characters long',
      ),
    );

    if (requireUppercase) {
      requirements.add(
        PasswordRequirement(
          description: 'At least one uppercase letter',
          validator: (password) => password.contains(RegExp('[A-Z]')),
          errorMessage: 'Password must contain at least one uppercase letter',
        ),
      );
    }

    if (requireLowercase) {
      requirements.add(
        PasswordRequirement(
          description: 'At least one lowercase letter',
          validator: (password) => password.contains(RegExp('[a-z]')),
          errorMessage: 'Password must contain at least one lowercase letter',
        ),
      );
    }

    if (requireNumbers) {
      requirements.add(
        PasswordRequirement(
          description: 'At least one number',
          validator: (password) => password.contains(RegExp('[0-9]')),
          errorMessage: 'Password must contain at least one number',
        ),
      );
    }

    if (requireSpecialChars) {
      requirements.add(
        PasswordRequirement(
          description: 'At least one special character',
          validator: (password) => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
          errorMessage: 'Password must contain at least one special character',
        ),
      );
    }

    if (checkCommonPasswords) {
      requirements.add(
        PasswordRequirement(
          description: 'Not a common password',
          validator: (password) {
            final commonPasswords = [
              'password',
              '123456',
              '12345678',
              '123456789',
              '1234567890',
              'qwerty',
              'letmein',
              'welcome',
              'admin',
              'password1',
              ...additionalCommonPasswords,
            ];
            return !commonPasswords.contains(password.toLowerCase());
          },
          errorMessage: 'Password is too common or easily guessable',
        ),
      );
    }

    return requirements;
  }

  PasswordStrength checkStrength(String password) {
    if (password.isEmpty) return PasswordStrength.tooWeak;

    // Check if any requirements are not met
    final unmetRequirements = requirements.where((req) => !req.validator(password)).length;

    // If any requirements are not met, consider it too weak
    if (unmetRequirements > 0) {
      return PasswordStrength.tooWeak;
    }

    // Use zxcvbn for more accurate strength estimation
    final result = Zxcvbn().evaluate(password);
    final score = result.score ?? 0;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.fair;
      case 3:
        return PasswordStrength.good;
      case 4:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.weak;
    }
  }

  bool meetsAllRequirements(String password) {
    return requirements.every((req) => req.validator(password));
  }

  List<String> validatePassword(String password) {
    return requirements.where((req) => !req.validator(password)).map((req) => req.errorMessage).toList();
  }

  String getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.tooWeak:
        return 'Too Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.tooWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.fair:
        return Colors.yellow[700]!;
      case PasswordStrength.good:
        return Colors.lightGreen;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}
