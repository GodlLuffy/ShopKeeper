import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class RatingService {
  static final RatingService instance = RatingService._();
  RatingService._();

  static const String _boxName = 'rating_box';
  static const String _sessionKey = 'session_count';
  static const String _ratedKey = 'already_rated';
  static const String _launchKey = 'first_launch';

  Future<void> initSession() async {
    final box = await Hive.openBox(_boxName);
    final sessionCount = (box.get(_sessionKey, defaultValue: 0) as int) + 1;
    await box.put(_sessionKey, sessionCount);
    
    if (sessionCount == 1) {
      await box.put(_launchKey, DateTime.now().toIso8601String());
    }
  }

  Future<bool> shouldShowRating() async {
    final box = await Hive.openBox(_boxName);
    final alreadyRated = box.get(_ratedKey, defaultValue: false) as bool;
    if (alreadyRated) return false;

    final sessionCount = box.get(_sessionKey, defaultValue: 0) as int;
    return sessionCount >= 5;
  }

  Future<void> markAsRated() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_ratedKey, true);
  }

  Future<void> snooze() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_sessionKey, 0);
  }

  Future<void> showRatingDialog(BuildContext context) async {
    final shouldShow = await shouldShowRating();
    if (!shouldShow || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkBackgroundLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: AppTheme.warningAmber, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enjoying ShopKeeper?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'We\'d love a 5-star rating if ShopKeeper is making your business management easier!',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              snooze();
            },
            child: const Text(
              'Later',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await markAsRated();
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thanks for your support! 🙏'),
                    backgroundColor: AppTheme.successEmerald,
                  ),
                );
              }
            },
            child: const Text(
              'Rate Now',
              style: TextStyle(
                color: AppTheme.warningAmber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
