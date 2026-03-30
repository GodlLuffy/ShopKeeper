import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:shop_keeper_project/core/constants/app_constants.dart';

class SettingsState {
  final double gstRate;
  final bool isDarkMode;

  const SettingsState({
    this.gstRate = 0.18,
    this.isDarkMode = true,
  });

  SettingsState copyWith({double? gstRate, bool? isDarkMode}) {
    return SettingsState(
      gstRate: gstRate ?? this.gstRate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final Box settingsBox;

  SettingsCubit(this.settingsBox) : super(_loadInitialState(settingsBox));

  static SettingsState _loadInitialState(Box box) {
    final gst = box.get('gst_rate', defaultValue: AppConstants.defaultGstRate);
    final dark = box.get('is_dark_mode', defaultValue: true);
    return SettingsState(gstRate: gst, isDarkMode: dark);
  }

  void updateGstRate(double newRate) {
    settingsBox.put('gst_rate', newRate);
    emit(state.copyWith(gstRate: newRate));
  }

  void toggleDarkMode(bool isDark) {
    settingsBox.put('is_dark_mode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }
}
