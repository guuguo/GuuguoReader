import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_repository.dart';

class InitLogic{
  static initialSource() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    // Save an integer value to 'counter' key.
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // if(await prefs.getString('lastVersion')==null){
    // }

    await prefs.setString('lastVersion', packageInfo.version);

  }
}