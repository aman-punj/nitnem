import 'package:flutter/material.dart';
import 'prayer_page.dart';

class ListingScreen extends StatelessWidget {
  const ListingScreen({super.key});

  final List<Map<String, dynamic>> banis = const [
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

  // For now, using Punjabi
  final String currentLang = 'pa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ਨਿਤਨੇਮ - Nitnem'),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'Nitnem Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Change Language'),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: banis.length,
        itemBuilder: (context, index) {
          final bani = banis[index];
          return Card(
            color: Colors.black,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.amberAccent),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                bani[currentLang],
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            ),
          );
        },
      ),
    );
  }
}
