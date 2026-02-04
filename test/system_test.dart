import 'package:flutter_test/flutter_test.dart';


///  FUNCTIONS

bool isValidStudentId(String id) {
  final regex = RegExp(r'^\d{10}$'); // exactly 10 digits
  return regex.hasMatch(id);
}

bool isValidPassword(String pass) {
  return pass.length >= 6;
}

bool isAssignmentValid(String title, String desc) {
  return title.isNotEmpty && desc.isNotEmpty;
}

String buildAdminEmail(String schoolId) {
  return "admin@$schoolId.edu.jo";
}

/// TEST CASES

void main() {

  /// TC1
  test('TC1 Valid student ID (10 digits)', () {
    expect(isValidStudentId("1234567890"), true);
  });

  /// TC2
  test('TC2 Student ID less than 10 digits', () {
    expect(isValidStudentId("12345"), false);
  });

  /// TC3
  test('TC3 Student ID more than 10 digits', () {
    expect(isValidStudentId("1234567890123"), false);
  });

  /// TC4
  test('TC4 Student ID contains letters', () {
    expect(isValidStudentId("12345abcde"), false);
  });

  /// TC5
  test('TC5 Password valid length', () {
    expect(isValidPassword("123456"), true);
  });

  /// TC6
  test('TC6 Assignment title or description missing', () {
    expect(isAssignmentValid("", "Homework"), false);
    expect(isAssignmentValid("Math HW", ""), false);
  });

  /// TC7
  test('TC7 Admin email format generation', () {
    expect(buildAdminEmail("ABC"), "admin@ABC.edu.jo");
  });

}
