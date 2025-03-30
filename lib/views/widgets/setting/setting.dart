import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTING',
          style: TextStyle(
            // fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Icon(FontAwesomeIcons.crown, color: Colors.green),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Image Container
          Container(
            width: double.infinity,
            height: 150, // Đặt kích thước cố định cho khung
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    // Ảnh lấp đầy khung
                    child: Image.asset(
                      'assets/images/cat.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    // Chữ "Hello" ở góc trên
                    top: 10,
                    left: 10,
                    child: Text(
                      'Hello',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic, // Chữ nghiêng
                        color: Colors.pink, // Chữ màu hồng
                        // backgroundColor: Colors.black54, // Nền giúp dễ đọc
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Container 1
          SettingsContainer(
            children: [
              SettingsItem(
                icon: Icons.calendar_today,
                iconColor: Colors.pink,
                title: 'Your Calendars',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: Icons.access_time,
                iconColor: Colors.green,
                title: '24-Hour Time',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: Colors.green,
                ),
              ),
              SettingsItem(
                icon: Icons.date_range,
                iconColor: Colors.blue,
                title: 'Date Format',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('dd/MM/yyyy', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              SettingsItem(
                icon: Icons.calendar_view_week,
                iconColor: Colors.purple,
                title: 'Start Week On',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Monday', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              SettingsItem(
                icon: Icons.calendar_today,
                iconColor: Colors.yellow,
                title: 'Show Week Numbers',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: Colors.green,
                ),
              ),
              SettingsItem(
                icon: Icons.calendar_today,
                iconColor: Colors.blue,
                title: 'Default View Mode',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Month View', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              SettingsItem(
                icon: Icons.check_box,
                iconColor: Colors.purple,
                title: 'Show To Do In Month View',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Colors.green,
                ),
              ),
              SettingsItem(
                icon: Icons.lock,
                iconColor: Colors.brown,
                title: 'Grant Permission',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: Icons.cloud,
                iconColor: Colors.red,
                title: 'Weather',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: Icons.calendar_today,
                iconColor: Colors.green,
                title: 'Interesting calendars',
                subtitle: '(Lunar Calendar, Moon phase)',
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 2
          SettingsContainer(
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.ribbon,
                iconColor: Colors.purple,
                title: 'Decorate',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.solidHeart,
                iconColor: Colors.orange,
                title: 'Sticker',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.solidImage,
                iconColor: Colors.pink,
                title: 'Background Effects',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.chevron_right, color: Colors.grey)],
                ),
              ),
              SettingsItem(
                icon: FontAwesomeIcons.palette,
                iconColor: Colors.teal,
                title: 'Theme',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.chevron_right, color: Colors.grey)],
                ),
              ),
              SettingsItem(
                icon: FontAwesomeIcons.font,
                iconColor: Colors.purple,
                title: 'Font',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.dollarSign,
                iconColor: Colors.green,
                title: 'Buy coin',
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 3
          SettingsContainer(
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.images,
                iconColor: Colors.pink,
                title: 'Photos',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.gift,
                iconColor: Colors.redAccent,
                title: 'Widget',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.clock,
                iconColor: Colors.orange,
                title: 'Countdown',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.tags,
                iconColor: Colors.green,
                title: 'Tag',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.folderOpen,
                iconColor: Colors.amber,
                title: 'Manage Categories',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.solidHeart,
                iconColor: Colors.red,
                title: 'Favorite Notes',
              ),
              SettingsItem(
                icon: Icons.archive,
                iconColor: Colors.blue,
                title: 'Archive Notes',
              ),
              SettingsItem(
                icon: Icons.push_pin,
                iconColor: Colors.green,
                title: 'Pin Notes',
              ),
              SettingsItem(
                icon: Icons.palette,
                iconColor: Colors.purple,
                title: 'Primary Color',
              ),
              SettingsItem(
                icon: Icons.cloud_upload,
                iconColor: Colors.blue,
                title: 'Sync and Backup',
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 4
          SettingsContainer(
            children: [
              SettingsItem(
                icon: Icons.lock,
                iconColor: Colors.orange,
                title: 'Passcode',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.crown, color: Colors.green),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              SettingsItem(
                icon: Icons.notifications,
                iconColor: Colors.blue,
                title: 'Notification',
              ),
              SettingsItem(
                icon: Icons.alarm,
                iconColor: Colors.red,
                title: 'Alarm',
              ),
              SettingsItem(
                icon: Icons.language,
                iconColor: Colors.red,
                title: 'Change language',
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 5
          SettingsContainer(
            children: [
              SettingsItem(
                icon: Icons.sync,
                iconColor: Colors.red,
                title: 'Automatic',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Colors.green,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      Radio(
                        value: true,
                        groupValue: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      Radio(
                        value: false,
                        groupValue: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 6
          SettingsContainer(
            children: [
              SettingsItem(
                icon: Icons.feedback,
                iconColor: Colors.green,
                title: 'Feedback',
              ),
              SettingsItem(
                icon: Icons.star,
                iconColor: Colors.blue,
                title: 'Rate',
              ),
              SettingsItem(
                icon: Icons.share,
                iconColor: Colors.orange,
                title: 'Share with friends',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.fileContract,
                iconColor: Colors.purple,
                title: 'Terms',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: FontAwesomeIcons.userShield,
                iconColor: Colors.red,
                title: 'Privacy Policy',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: FontAwesomeIcons.thLarge,
                iconColor: Colors.teal,
                title: 'More apps',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Container 7
          SettingsContainer(
            title: 'Follow me',
            children: [
              SettingsItem(
                icon: FontAwesomeIcons.tiktok,
                iconColor: Colors.black,
                title: 'Tiktok',
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
              SettingsItem(
                icon: FontAwesomeIcons.youtube,
                iconColor: Colors.red,
                title: 'Youtube',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.facebook,
                iconColor: Colors.blue,
                title: 'Facebook',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.pinterest,
                iconColor: Colors.redAccent,
                title: 'Pinterest',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.instagram,
                iconColor: Colors.purple,
                title: 'Instagram',
              ),
            ],
          ),
        ],
      ),
      // bottomNavigationBar: BottomAppBar(
      //   shape: CircularNotchedRectangle(),
      //   notchMargin: 6.0,
      //   child: Container(
      //     height: 60,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.calendar_today, color: Colors.grey),
      //             Text(
      //               'Calendar',
      //               style: TextStyle(color: Colors.grey, fontSize: 12),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.task, color: Colors.grey),
      //             Text(
      //               'Manage',
      //               style: TextStyle(color: Colors.grey, fontSize: 12),
      //             ),
      //           ],
      //         ),
      //         SizedBox(width: 48), // The dummy child
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.emoji_events, color: Colors.grey),
      //             Text(
      //               'Challenge',
      //               style: TextStyle(color: Colors.grey, fontSize: 12),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.settings, color: Colors.green),
      //             Text(
      //               'Setting',
      //               style: TextStyle(color: Colors.green, fontSize: 12),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      // // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.green,
      // ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  SettingsContainer({required this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle, // Không bắt buộc
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title:
          subtitle == null
              ? Text(title, style: TextStyle(fontWeight: FontWeight.bold))
              : RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $subtitle',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
