import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardiocare/services/preferences.dart';

class DemoSettingsScreen extends StatelessWidget {
  const DemoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Settings'),
      ),
      body: Consumer<SharedPreferencesManager>(
        builder: (context, prefManager, child) {
          final appSettings = prefManager.appSettings;
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Demo Mode'),
                value: appSettings.isDemoMode,
                onChanged: (bool value) {
                  prefManager.updateAppSettings(
                    appSettings.copyWith(
                      isDemoMode: value,
                      isDemoUser: value ? appSettings.isDemoUser : false,
                      isVirtualDevice:
                          value ? appSettings.isVirtualDevice : false,
                    ),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Demo User'),
                value: appSettings.isDemoUser,
                onChanged: appSettings.isDemoMode
                    ? (bool value) {
                        prefManager.updateAppSettings(
                          appSettings.copyWith(isDemoUser: value),
                        );
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Virtual Device'),
                value: appSettings.isVirtualDevice,
                onChanged: appSettings.isDemoMode
                    ? (bool value) {
                        prefManager.updateAppSettings(
                          appSettings.copyWith(isVirtualDevice: value),
                        );
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
