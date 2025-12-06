class BankAccount {
  final int id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final bool isActive;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.isActive,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankName: json['bank_name'],
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      isActive: json['is_active'] ?? true,
    );
  }
}
