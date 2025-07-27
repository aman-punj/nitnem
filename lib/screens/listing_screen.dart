import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nitnem/screens/feedback_screen.dart';

import 'prayer_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> baniList = const [
    {
      'id': 'japji_sahib',
      'pa': 'ਜਪੁਜੀ ਸਾਹਿਬ',
      'hi': 'जपुजी साहिब',
      'en': 'Japji Sahib',
    },
    {
      'id': 'jaap_sahib',
      'pa': 'ਜਾਪ ਸਾਹਿਬ',
      'hi': 'जाप साहिब',
      'en': 'Jaap Sahib',
    },
    {
      'id': 'tav_prasad_savaiye',
      'pa': 'ਤਵ ਪ੍ਰਸਾਦ ਸਵੱਯੇ',
      'hi': 'तव प्रसाद सवये',
      'en': 'Tav Prasad Savaiye',
    },
    {
      'id': 'chaupai_sahib',
      'pa': 'ਚੌਪਈ ਸਾਹਿਬ',
      'hi': 'चौपई साहिब',
      'en': 'Chaupai Sahib',
    },
    {
      'id': 'anand_sahib',
      'pa': 'ਆਨੰਦ ਸਾਹਿਬ',
      'hi': 'आनंद साहिब',
      'en': 'Anand Sahib',
    },
  ];


  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;

    return Scaffold(
      drawer: HomeDrawer(
        onItemSelected: (item) {
          Navigator.pop(context);
          switch (item.id) {
            case 'language': // show dialog or redirect
              break;
            case 'feedback':
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return FeedbackScreen();
              }));
              break;
            case 'exit': // show confirm dialog
              break;
          // and so on
          }
        },
      ),      appBar: AppBar(
        title: Text('app_name'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: baniList.length,
          itemBuilder: (context, index) {
            final bani = baniList[index];
            return BaniListTile(
              // baniId: bani['id']!,
    onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrayerPage(
                      title: 'Japji Sahib',
                      audioAssetPath: 'assets/audios/Japji_Sahib.mp3',
                      transcriptAssetPath: 'assets/texts/Japji_Sahib.json',
                    ),
                  ),
                );
              },
              title: bani[currentLang] ?? bani['pa']!,
            );
          },
        ),
      ),
    );
  }
}



class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.onItemSelected});

  final Function(DrawerItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/khanda_image.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'nBani',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                  ),
                  const Text(
                    'Spiritual Bani Reader',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ...drawerItems.map((item) => ListTile(
              leading: Icon(item.icon, color: Colors.white),
              title: Text(item.title, style: const TextStyle(color: Colors.white)),
              onTap: () => onItemSelected(item),
            )),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('© 2025 nBani • All rights reserved', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}



class DrawerItem {
  final String title;
  final IconData icon;
  final String id;

  const DrawerItem({required this.title, required this.icon, required this.id});
}

const List<DrawerItem> drawerItems = [
  DrawerItem(title: 'Change Language', icon: Icons.language, id: 'language'),
  DrawerItem(title: 'Share App', icon: Icons.share, id: 'share'),
  DrawerItem(title: 'Feedback', icon: Icons.feedback, id: 'feedback'),
  DrawerItem(title: 'Rate Us', icon: Icons.star_rate, id: 'rate'),
  DrawerItem(title: 'Privacy Policy', icon: Icons.privacy_tip, id: 'privacy'),
  DrawerItem(title: 'About App', icon: Icons.info_outline, id: 'about'),
  DrawerItem(title: 'Exit', icon: Icons.exit_to_app, id: 'exit'),
];

class BaniListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const BaniListTile({
    super.key,
     this.icon = Icons.gradient,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.amberAccent),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.grey[900],
    );
  }
}
