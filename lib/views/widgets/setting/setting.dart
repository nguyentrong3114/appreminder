import 'settings_item.dart';
import 'settings_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTING',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(FontAwesomeIcons.crown, color: Colors.green),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea( // <-- Thêm dòng này
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

            // General
            SettingsSection(
              children: [
                SettingsItem(icon: Icons.calendar_today, iconColor: Colors.pink, title: 'Your Calendars'),
                SettingsItem(
                  icon: Icons.access_time,
                  iconColor: Colors.green,
                  title: '24-Hour Time',
                  trailing: Switch(
                    value: context.watch<TimeFormatProvider>().use24HourFormat,
                    onChanged: (value) {
                      context.read<TimeFormatProvider>().setUse24HourFormat(value);
                    },
                  ),
                ),
                SettingsItem(icon: Icons.date_range, iconColor: Colors.blue, title: 'Date Format', trailing: const Text('dd/MM/yyyy', style: TextStyle(color: Colors.grey))),
                SettingsItem(icon: Icons.calendar_view_week, iconColor: Colors.purple, title: 'Start Week On', trailing: const Text('Monday', style: TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 16),

            // Appearance
            SettingsSection(
              title: 'Appearance',
              children: [
                SettingsItem(icon: FontAwesomeIcons.palette, iconColor: Colors.teal, title: 'Theme'),
                SettingsItem(icon: FontAwesomeIcons.font, iconColor: Colors.purple, title: 'Font'),
              ],
            ),
            const SizedBox(height: 16),

            // Security & Notification
            SettingsSection(
              title: 'Security & Notification',
              children: [
                SettingsItem(icon: Icons.lock, iconColor: Colors.orange, title: 'Passcode'),
                SettingsItem(icon: Icons.notifications, iconColor: Colors.blue, title: 'Notification'),
              ],
            ),
            const SizedBox(height: 16),

            // About
            SettingsSection(
              title: 'About',
              children: [
                SettingsItem(icon: Icons.feedback, iconColor: Colors.green, title: 'Feedback'),
                SettingsItem(icon: Icons.star, iconColor: Colors.blue, title: 'Rate'),
                SettingsItem(icon: Icons.share, iconColor: Colors.orange, title: 'Share with friends'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
