class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Time complexity: O(n)
  bool hasDuplicates(List<int> list) {
    Set<int> seen = {};
    for (int num in list) {
      if (seen.contains(num)) return true;
      seen.add(num);
    }
    return false;
  }
}