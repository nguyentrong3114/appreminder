import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/provider/setting_provider.dart';

class VipUpgradeDialog extends StatefulWidget {
  const VipUpgradeDialog({super.key});

  @override
  State<VipUpgradeDialog> createState() => _VipUpgradeDialogState();
}

class _VipUpgradeDialogState extends State<VipUpgradeDialog> with WidgetsBindingObserver {
  bool _pendingVip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncVipFromFirestore();
  }

  Future<void> _syncVipFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isVipRemote = doc.data()?['isVip'] == true;
      if (context.mounted) {
        await context.read<SettingProvider>().setVip(isVipRemote);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingVip) {
      _pendingVip = false;
      _activateVip();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kích hoạt VIP thành công !')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _activateVip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'isVip': true}, SetOptions(merge: true)); 
      if (context.mounted) {
        final settingProvider = context.read<SettingProvider>();
        await settingProvider.setVip(true);
      }
    }
  }

  Future<void> _payWithStripe(BuildContext context) async {
    const String publishableKey = ''; 
    Stripe.publishableKey = publishableKey;
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: '', 
          merchantDisplayName: 'App Reminder',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công!')));
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi Stripe: \\${e.error.localizedMessage}')));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: \\${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVip = context.watch<SettingProvider>().isVip;
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          SizedBox(width: 10),
          Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Quyền lợi khi nâng cấp VIP:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Không quảng cáo'),
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Sao lưu & đồng bộ dữ liệu'),
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Tùy chỉnh giao diện cao cấp'),
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Hỗ trợ ưu tiên'),
          ),
          SizedBox(height: 16),
          Text('Chỉ với 49.000đ/tháng hoặc 399.000đ/năm!', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.payment),
          label: const Text('Thanh toán qua Stripe'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
          onPressed: isVip
              ? null
              : () async {
                  final url = Uri.parse('https://buy.stripe.com/test_6oUfZh4HD9l66nO39cfjG00');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                    setState(() {
                      _pendingVip = true;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không mở được link thanh toán!')));
                  }
                },
        ),
      ],
    );
  }
}
