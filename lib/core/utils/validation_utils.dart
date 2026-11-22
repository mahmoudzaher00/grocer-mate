// import 'extensions/validation_extensions.dart';
// import 'package:material_ui/material_ui.dart';
//
//
//
// class ValidationUtils {
//   static String? requiredFieldMessage(String? value, {String? widgetName, bool isRequired = true}) {
//     if (!isRequired) return null;
//
//     if (value == null || value.trim().isEmpty) {
//       final String normalizedWidgetName = widgetName?.trim() ?? '';
//
//       if (normalizedWidgetName.isEmpty) {
//         return AppStrings.requiredField.tr();
//       }
//
//       return '$normalizedWidgetName ${AppStrings.requiredMasculine.tr()}';
//     }
//
//     return null;
//   }
//
//   static String? validateRequiredField(String? input) {
//     final String normalized = input?.trim() ?? '';
//     if (normalized.isEmpty) {
//       return AppStrings.requiredFieldValidation.tr();
//     }
//     return null;
//   }
//
//   static String? validateString(String? input, {int maxLength = 1000, int minLength = 3, String? widgetName, ArabicGender gender = ArabicGender.masculine}) {
//     if (input == null || input.isEmpty || input.length > maxLength) {
//       return '${widgetName ?? ''} '
//           '${gender == ArabicGender.feminine ? AppStrings.requiredFeminine.tr() : AppStrings.requiredMasculine.tr()}';
//     }
//
//     if (input.trim().length < minLength) {
//       return '${widgetName ?? ''} ${AppStrings.shouldBeLeast.tr()} $minLength ${AppStrings.characters.tr()}';
//     }
//
//     return null;
//   }
//
//   static String? validateNumber(String? input, {int minLength = 3, int maxLength = 9, String? widgetName}) {
//     if (input == null || input.trim().length < minLength || input.isEmpty) {
//       return '$widgetName ${'must_be_at_least'} $minLength ${'numbers'}';
//     }
//     if (input.trim().length > maxLength) {
//       return '$widgetName ${'must_be_only'} $minLength ${'numbers'}';
//     }
//
//     // if ((double.parse(input)) <= 0) return 'invalid_entry';
//     return null;
//   }
//
//   static String? validatePassword(String? input, {int maxLength = 1000, int minLength = 3, FocusNode? node, bool useStrongValidation = true}) {
//     if (input == null || input.isEmpty || input.length > maxLength) {
//       if (node != null) {
//         node.requestFocus();
//         return AppStrings.wrongPassword.tr();
//       } else {
//         return AppStrings.passwordRequired.tr();
//       }
//     } else if (input.trim().length < minLength) {
//       return '${AppStrings.passwordShouldBe.tr()} $minLength ${AppStrings.numbers.tr()}';
//     } else if (useStrongValidation && !input.toString().isValidPassword(minLength)) {
//       return AppStrings.passwordMatchError.tr();
//     } else {
//       return null;
//     }
//   }
//
//   static String? confirmPassword(String? input, {String? password}) {
//     if (input == null || input.isEmpty) {
//       return AppStrings.passwordRequired.tr();
//     } else if (input.trim() != password) {
//       return AppStrings.passwordNotMatched.tr();
//     } else {
//       return null;
//     }
//   }
//
//   static String? validateEmail(String? input) {
//     if (input == null || input.isEmpty) {
//       return AppStrings.emailRequired.tr();
//     } else if (!input.isValidEmail()) {
//       return AppStrings.invalidEmailAddress.tr();
//     } else {
//       return null;
//     }
//   }
//
//   static String? validatePhoneNumber(String? input, {int length = 9}) {
//     if (input == null || input.isEmpty) return AppStrings.phoneRequired.tr();
//     if (input.trim().length != length) {
//       return '${AppStrings.phoneShouldBe.tr()} $length ${AppStrings.numbers.tr()}';
//     }
//     // if (input.characters.first != '5') return 'phone_must_start_with5';
//     if ((double.parse(input)) <= 0) return AppStrings.wrongPhoneNumber.tr();
//     return null;
//   }
//
//   static String? validateZeroToHundredNumber(String? input, {bool allowEmpty = true, String? widgetName}) {
//     return validateZeroToMaximumNumber(
//       input,
//       maximum: 100,
//       allowEmpty: allowEmpty,
//       widgetName: widgetName,
//     );
//   }
//
//   static String? validateZeroToMaximumNumber(String? input, {required int maximum, bool allowEmpty = true, String? widgetName}) {
//     final String normalized = input?.trim() ?? '';
//
//     if (normalized.isEmpty) {
//       if (allowEmpty) return null;
//
//       final String requiredMessage = AppStrings.requiredField.tr();
//       final String? name = widgetName?.trim();
//
//       return name == null || name.isEmpty ? requiredMessage : '$name $requiredMessage';
//     }
//
//     final int? value = int.tryParse(normalized);
//     if (value == null || value < 0 || value > maximum) {
//       return AppStrings.enterValueBetweenZeroAndMaximum.tr(namedArgs: <String, String>{'max': maximum.toString()});
//     }
//
//     return null;
//   }
//
// }
