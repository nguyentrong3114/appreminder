import 'chart.dart';
import 'profile.dart';
import 'statistical.dart';
import 'settings_item.dart';
import 'change_password.dart';
import 'settings_section.dart';
import 'vip_upgrade_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() => context.read<SettingProvider>().syncVipStatusFromFirestore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SettingProvider>().syncVipStatusFromFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CÀI ĐẶT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.crown, color: Colors.green),
          tooltip: 'Nâng cấp VIP',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const VipUpgradeDialog(),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar/Banner
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/cat.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const ProfileWidget(),
            // General
            SettingsSection(
              children: [
                SettingsItem(
                  icon: Icons.calendar_today,
                  iconColor: Colors.pink,
                  title: 'Lịch của bạn',
                ),
                SettingsItem(
                  icon: Icons.access_time,
                  iconColor: Colors.green,
                  title: 'Định dạng 24h',
                  trailing: Switch(
                    value: context.watch<SettingProvider>().use24HourFormat,
                    onChanged: (value) {
                      context.read<SettingProvider>().setUse24HourFormat(value);
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.date_range,
                  iconColor: Colors.blue,
                  title: 'Định dạng ngày',
                  trailing: Text(
                    context.watch<SettingProvider>().dateFormat,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    final formats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'];
                    String tempValue =
                        context.read<SettingProvider>().dateFormat;
                    final value = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn định dạng ngày'),
                          content: StatefulBuilder(
                            builder:
                                (context, setState) => DropdownButton<String>(
                                  value: tempValue,
                                  isExpanded: true,
                                  items:
                                      formats
                                          .map(
                                            (f) => DropdownMenuItem(
                                              value: f,
                                              child: Text(f),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null)
                                      setState(() => tempValue = v);
                                  },
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(context, tempValue),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (value != null) {
                      context.read<SettingProvider>().setDateFormat(value);
                    }
                  },
                ),
                SettingsItem(
                  icon: Icons.calendar_view_week,
                  iconColor: Colors.purple,
                  title: 'Bắt đầu tuần',
                  trailing: Text(
                    context.watch<SettingProvider>().startWeekOn == 6
                        ? 'Chủ nhật'
                        : 'Thứ ${context.watch<SettingProvider>().startWeekOn + 2}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    int tempValue = context.read<SettingProvider>().startWeekOn;
                    final value = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn ngày bắt đầu tuần'),
                          content: StatefulBuilder(
                            builder:
                                (context, setState) => DropdownButton<int>(
                                  value: tempValue,
                                  isExpanded: true,
                                  items: List.generate(
                                    7,
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(
                                        i == 6 ? 'Chủ nhật' : 'Thứ ${i + 2}',
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    if (v != null)
                                      setState(() => tempValue = v);
                                  },
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(context, tempValue),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (value != null) {
                      context.read<SettingProvider>().setStartWeekOn(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Appearance
            SettingsSection(
              title: 'Giao diện',
              children: [
                SettingsItem(
                  icon: FontAwesomeIcons.palette,
                  iconColor: Colors.teal,
                  title: 'Chủ đề',
                ),
                SettingsItem(
                  icon: Icons.font_download,
                  iconColor: Colors.deepOrange,
                  title: 'Phông chữ',
                  trailing: Text(
                    context.watch<SettingProvider>().fontFamily,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    final isVip = context.read<SettingProvider>().isVip;
                    if (!isVip) {
                      // Nếu chưa VIP, mở dialog nâng cấp VIP
                      showDialog(
                        context: context,
                        builder: (context) => const VipUpgradeDialog(),
                      );
                      return;
                    }
                    final fonts = [
                      'Roboto',
                      'Montserrat',
                      'Lobster',
                      'Oswald',
                      'Raleway',
                      'Ubuntu',
                    ];
                    String tempValue =
                        context.read<SettingProvider>().fontFamily;
                    final value = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn font chữ'),
                          content: StatefulBuilder(
                            builder:
                                (context, setState) => DropdownButton<String>(
                                  value: tempValue,
                                  isExpanded: true,
                                  items:
                                      fonts
                                          .map(
                                            (f) => DropdownMenuItem(
                                              value: f,
                                              child: Text(
                                                f,
                                                style: TextStyle(fontFamily: f),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null)
                                      setState(() => tempValue = v);
                                  },
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(context, tempValue),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (value != null) {
                      context.read<SettingProvider>().setFontFamily(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Security & Notification
            SettingsSection(
              title: 'Quyền riêng tư & Thông báo',
              children: [
                SettingsItem(
                  icon: Icons.lock,
                  iconColor: Colors.orange,
                  title: 'Mật mã',
                ),
                SettingsItem(
                  icon: Icons.notifications,
                  iconColor: Colors.blue,
                  title: 'Âm thanh thông báo',
                  trailing: Text(
                    context.watch<SettingProvider>().notificationSound,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    final sounds = {
                      'Âm thanh 1': 'noti1',
                      'Âm thanh 2': 'noti2',
                      'Âm thanh 3': 'noti3',
                      'Âm thanh 4': 'noti4',
                      'Âm thanh 5': 'noti5',
                      'Âm thanh 6': 'noti6',
                    };
                    String selectedSound =
                        context.read<SettingProvider>().notificationSound;
                    final player = AudioPlayer();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn âm thanh thông báo'),
                          content: StatefulBuilder(
                            builder:
                                (context, setState) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      sounds.entries.map((entry) {
                                        return RadioListTile<String>(
                                          title: Text(entry.key),
                                          value: entry.value,
                                          groupValue: selectedSound,
                                          onChanged: (value) async {
                                            if (value != null) {
                                              setState(
                                                () => selectedSound = value,
                                              );
                                              await player.stop();
                                              await player.play(
                                                AssetSource('noti/$value.mp3'),
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                player.stop();
                                Navigator.pop(context);
                              },
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                player.stop();
                                context
                                    .read<SettingProvider>()
                                    .setNotificationSound(selectedSound);
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: Text(
                                          'Đã chọn: $selectedSound',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.alarm,
                  iconColor: Colors.red,
                  title: 'Âm thanh báo thức',
                  trailing: Builder(
                    builder: (context) {
                      final sound =
                          context.watch<SettingProvider>().notificationSound;
                      return Text(
                        sound.isNotEmpty ? sound : 'alarm1',
                        style: const TextStyle(color: Colors.grey),
                      );
                    },
                  ),
                  onTap: () async {
                    final sounds = {
                      'Báo thức 1': 'alarm1',
                      'Báo thức 2': 'alarm2',
                      'Báo thức 3': 'alarm3',
                      'Báo thức 4': 'alarm4',
                      'Báo thức 5': 'alarm5',
                    };
                    String selectedSound =
                        context
                                .read<SettingProvider>()
                                .notificationSound
                                .isNotEmpty
                            ? context.read<SettingProvider>().notificationSound
                            : 'alarm1';
                    final player = AudioPlayer();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chọn âm thanh báo thức'),
                          content: StatefulBuilder(
                            builder:
                                (context, setState) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      sounds.entries.map((entry) {
                                        return RadioListTile<String>(
                                          title: Text(entry.key),
                                          value: entry.value,
                                          groupValue: selectedSound,
                                          onChanged: (value) async {
                                            if (value != null) {
                                              setState(
                                                () => selectedSound = value,
                                              );
                                              await player.stop();
                                              await player.play(
                                                AssetSource(
                                                  'sounds/$value.mp3',
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                player.stop();
                                Navigator.pop(context);
                              },
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                player.stop();
                                context
                                    .read<SettingProvider>()
                                    .setNotificationSound(selectedSound);
                                context.read<SettingProvider>().setAlarmSound(
                                  selectedSound,
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã chọn: $selectedSound'),
                                  ),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics
            SettingsSection(
              title: 'Thống kê',
              children: [
                SettingsItem(
                  icon: Icons.analytics,
                  iconColor: Colors.deepPurple,
                  title: 'Thống kê',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StatisticalPage(),
                      ),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.bar_chart,
                  iconColor: Colors.indigo,
                  title: 'Biểu đồ',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => const StatisticalPage(showChartOnly: true),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About
            SettingsSection(
              title: 'Về chúng tôi',
              children: [
                SettingsItem(
                  icon: Icons.feedback,
                  iconColor: Colors.green,
                  title: 'Phản hồi',
                ),
                SettingsItem(
                  icon: Icons.star,
                  iconColor: Colors.blue,
                  title: 'Đánh giá',
                ),
                SettingsItem(
                  icon: Icons.share,
                  iconColor: Colors.orange,
                  title: 'Chia sẻ với bạn bè',
                ),
                SettingsItem(
                  icon: Icons.lock,
                  iconColor: Colors.purple,
                  title: 'Change Password',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ChangePasswordWidget(),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'Đăng xuất',
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
