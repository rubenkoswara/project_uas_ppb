import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../providers/database_providers.dart';

class AdminBankAccountPage extends StatelessWidget {
  const AdminBankAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Akun Bank')),
      body: StreamBuilder(
        stream: supabase
            .from('bank_accounts')
            .stream(primaryKey: ['id'])
            .order('id'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final accounts = snapshot.data!
              .map((json) => BankAccount.fromJson(json))
              .toList();

          if (accounts.isEmpty)
            return const Center(
              child: Text('Belum ada akun bank yang terdaftar.'),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: account.isActive ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    account.bankName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('A/N: ${account.accountName}'),
                      Text('No. Rek: ${account.accountNumber}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      account.isActive
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 20,
                            ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminAddEditBankAccount(account: account),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await supabase
                              .from('bank_accounts')
                              .delete()
                              .eq('id', account.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00838F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAddEditBankAccount()),
        ),
      ),
    );
  }
}

class AdminAddEditBankAccount extends StatefulWidget {
  final BankAccount? account;
  const AdminAddEditBankAccount({super.key, this.account});

  @override
  State<AdminAddEditBankAccount> createState() =>
      _AdminAddEditBankAccountState();
}

class _AdminAddEditBankAccountState extends State<AdminAddEditBankAccount> {
  final _formKey = GlobalKey<FormState>();
  final bankNameCtrl = TextEditingController();
  final accountNameCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  bool isActive = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      bankNameCtrl.text = widget.account!.bankName;
      accountNameCtrl.text = widget.account!.accountName;
      accountNumberCtrl.text = widget.account!.accountNumber;
      isActive = widget.account!.isActive;
    }
  }

  void save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final data = {
      'bank_name': bankNameCtrl.text,
      'account_name': accountNameCtrl.text,
      'account_number': accountNumberCtrl.text,
      'is_active': isActive,
    };

    if (widget.account != null) {
      await supabase
          .from('bank_accounts')
          .update(data)
          .eq('id', widget.account!.id);
    } else {
      await supabase.from('bank_accounts').insert(data);
    }

    if (mounted) Navigator.pop(context);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.account != null ? 'Edit Akun Bank' : 'Tambah Akun Bank',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: bankNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Bank (Contoh: BCA)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: accountNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Pemilik Akun',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: accountNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktifkan Metode Pembayaran'),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00838F),
                  foregroundColor: Colors.white,
                ),
                onPressed: loading ? null : save,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Akun Bank'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
