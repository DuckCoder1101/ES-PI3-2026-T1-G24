class Validator {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return (email.isNotEmpty && emailRegex.hasMatch(email));
  }

  static bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,16}$');
    return (password.isNotEmpty && passwordRegex.hasMatch(password));
  }
}
