import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/Provider/scheduling_provider.dart';
import 'package:restaurant/Provider/sharedPref_provider.dart';
import 'package:restaurant/Service/Connectivity.dart';

class SettingsPage extends StatelessWidget {
  static const String settingsTitle = 'Settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(settingsTitle),
      ),
      body: Consumer<SharedPrefProvider>(
        builder: (context, provider, child) {
          return Consumer<ConnectivityProvider>(
            builder: (context, connectivityModel, child) {
              if (connectivityModel.status == ConnectivityStatus.Offline) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Anda sedang offline.',
                        textAlign: TextAlign.center,
                      ),
                      Text('Silahkan hubungkan ke jaringan internet !!!')
                    ],
                  ),
                );
              } else {
                return Material(
                  child: ListTile(
                    title: const Text('Scheduling Restaurant'),
                    trailing: Consumer<SchedulingProvider>(
                      builder: (context, scheduled, _) {
                        return Switch.adaptive(
                          value: provider.isDailyActive,
                          onChanged: (value) async {
                            scheduled.scheduledRestaurant(value);
                            provider.enableDailyActive(value);
                          },
                        );
                      },
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
