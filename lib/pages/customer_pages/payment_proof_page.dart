import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/bank_account.dart';
import '../../providers/database_providers.dart';

class PaymentProofPage extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  const PaymentProofPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentProofPage> createState() => _PaymentProofPageState();
}

class _PaymentProofPageState extends State<PaymentProofPage> {
  XFile? pickedImage;
  bool uploading = false;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<List<BankAccount>> fetchActiveBankAccounts() async {
    try {
      final response = await supabase
          .from('bank_accounts')
          .select()
          .eq('is_active', true);
      return response.map((json) => BankAccount.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching bank accounts: $e');
      return [];
    }
  }

  Future<void> _pickImage() async {
    if (uploading) return;

    setState(() {
      uploading = true;
    });

    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (img != null) {
        setState(() {
          pickedImage = img;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih gambar. Coba lagi.')),
        );
      }
    } finally {
      setState(() {
        uploading = false;
      });
    }
  }

  Future<void> uploadProof() async {
    if (pickedImage == null || uploading) {
      if (pickedImage == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih bukti transfer terlebih dahulu.'),
          ),
        );
      }
      return;
    }

    setState(() => uploading = true);

    final file = File(pickedImage!.path);
    final path =
        'proofs/order_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await supabase.storage.from('proofs').upload(path, file);
      final publicUrl = supabase.storage.from('proofs').getPublicUrl(path);

      await supabase
          .from('orders')
          .update({'status': 'Pending', 'payment_proof_url': publicUrl})
          .eq('id', widget.orderId);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bukti Pembayaran Berhasil Diunggah'),
            content: Text(
              'Order #${widget.orderId} akan segera diproses oleh Admin. Terima kasih.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Upload Error: $e');
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah bukti: $e')));
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Pesanan'),
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<BankAccount>>(
        future: fetchActiveBankAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat rekening bank: ${snapshot.error}'),
            );
          }

          final accounts = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Total yang Harus Dibayar:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                currencyFormatter.format(widget.totalAmount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Divider(),

              const Text(
                'Silakan Transfer ke salah satu rekening berikut:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (accounts.isEmpty)
                const Card(
                  color: Colors.red,
                  child: ListTile(
                    title: Text(
                      'Admin belum mengatur metode pembayaran.',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Hubungi Admin Toko.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                ...accounts.map(
                  (acc) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${acc.bankName} - ${acc.accountNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00838F),
                        ),
                      ),
                      subtitle: Text('A/N: ${acc.accountName}'),
                    ),
                  ),
                ),

              const Divider(),

              const Text(
                'Unggah Bukti Pembayaran:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              pickedImage == null
                  ? Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: uploading ? null : _pickImage,
                          icon: uploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(
                            uploading
                                ? 'Memproses...'
                                : 'Pilih Screenshot Bukti Transfer',
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(pickedImage!.path),
                            height: 150,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        TextButton(
                          onPressed: uploading ? null : _pickImage,
                          child: const Text('Ganti Bukti Transfer'),
                        ),
                      ],
                    ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00838F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: uploading || pickedImage == null
                      ? null
                      : uploadProof,
                  child: uploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
