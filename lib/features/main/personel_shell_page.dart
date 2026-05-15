import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';

import '../appointments/presentation/appointments_page.dart';
import '../calisma_saatleri/sunum/calisma_saatleri.dart';
import '../reviews/presentation/reviews_page.dart';
import '../profile/presentation/profile_page.dart';

class PersonelShellPage extends StatefulWidget {
  const PersonelShellPage({super.key});

  @override
  State<PersonelShellPage> createState() => _PersonelShellPageState();
}

class _PersonelShellPageState extends State<PersonelShellPage> {
  int index = 0;

  final Color primary = const Color(0xFF2563EB);

  late final Dio dio;

  @override
  void initState() {
    super.initState();
    dio = DioClient.create();
  }

  late final pages = [
    const AppointmentsPage(),

    CalismaSaatlerimSayfasi(dio: dio),

    ReviewsPage(primary: primary),

    ProfilePage(primary: primary),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Randevular',
          ),

          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Saatlerim',
          ),

          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Yorumlar',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
