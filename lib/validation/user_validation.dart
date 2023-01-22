String? validateAddressField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? validateNameField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateEmailField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(value)) {
      return null;
    }
    return 'Email address is invalid';
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required!';
    }
    if (!RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).{6,13}$')
        .hasMatch(value)) {
      return "Password must contain at least 1 lowercase, 1 uppercase, a number and a number and must be 6 to 13 characters long";
    }
    return null;
  }

  String? validateConfirmPass(String? confirmPassword, String? password) {
    if (confirmPassword == null) {
      return "Confirm password is required!";
    }
    if (password == null || confirmPassword != password) {
      return "Confirm password does not match!";
    }
    return null;
  }