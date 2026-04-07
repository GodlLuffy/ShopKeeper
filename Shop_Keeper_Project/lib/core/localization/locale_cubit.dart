import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';

class LocaleCubit extends Cubit<AppLanguage> {
  LocaleCubit() : super(AppLanguage.english) {
    AppStrings.currentLanguage = state;
  }

  void setLanguage(AppLanguage language) {
    AppStrings.currentLanguage = language;
    emit(language);
  }

  void toggleLanguage() {
    final next = state == AppLanguage.english ? AppLanguage.hindi : AppLanguage.english;
    setLanguage(next);
  }
}
