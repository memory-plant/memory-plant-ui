import 'package:flutter/material.dart';
import 'package:memory_plant_application/providers/language_provider.dart';
import 'package:memory_plant_application/styles/app_styles.dart';
import 'package:provider/provider.dart';

class LanguageToggleSwitch extends StatefulWidget {
  const LanguageToggleSwitch({
    super.key,
  });

  @override
  State<LanguageToggleSwitch> createState() => _LanguageToggleSwitchState();
}

class _LanguageToggleSwitchState extends State<LanguageToggleSwitch> {
  void _toggleSwitch(bool value) {
    context.read<LanguageProvider>().changeLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
        value: context.watch<LanguageProvider>().currentLanguage == Language.ko,
        onChanged: _toggleSwitch,
        activeColor: Colors.white,
        activeTrackColor: AppStyles.maindeepblue);
  }
}
