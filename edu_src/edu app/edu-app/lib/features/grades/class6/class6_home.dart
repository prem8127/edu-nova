import 'package:flutter/material.dart';

import '../../../core/theme/grade_themes.dart';
import '../grade_nav.dart';
import 'effects/adventure_effects.dart';
import 'models.dart';
import 'theme/adventure_theme.dart';
import 'widgets/buddy_pet_games.dart';
import 'widgets/castle_and_chest.dart';
import 'widgets/hero_and_missions.dart';
import 'widgets/rewards_and_social.dart';

/// Class 6 Student Dashboard — "Adventure Learning World".
///
/// A single scrollable adventure map: hero banner, daily quests, an AI
/// buddy & pet companion, mini-games, a reward economy (XP, badges,
/// leaderboard, weekly challenge) and the signature Progress Castle +
/// Magic Treasure Chest that turn the child's report card into a game.
class Class6Home extends StatefulWidget {
  const Class6Home({super.key});

  @override
  State<Class6Home> createState() => _Class6HomeState();
}

class _Class6HomeState extends State<Class6Home> {
  final ConfettiController _confetti = ConfettiController();

  // ---- Explorer state -----------------------------------------------
  final String _name = 'Aarav';
  int _level = 7;
  int _xp = 2350;
  final int _xpTarget = 3000;
  int _streak = 6;
  int _coins = 480;

  // ---- Missions -------------------------------------------------------
  late final List<Mission> _missions = [
    Mission(title: 'Finish 1 Math lesson', xp: 30, icon: Icons.calculate_rounded, color: AdventureColors.blue, done: true),
    Mission(title: 'Play a Science mini-game', xp: 25, icon: Icons.science_rounded, color: AdventureColors.lime, done: true),
    Mission(title: 'Read for 10 minutes', xp: 20, icon: Icons.menu_book_rounded, color: AdventureColors.yellowDeep),
    Mission(title: 'Answer 5 quiz questions', xp: 25, icon: Icons.quiz_rounded, color: AdventureColors.orange),
  ];

  // ---- AI Buddy tips ----------------------------------------------------
  final List<String> _tips = [
    '"Fractions are just pizza slices in disguise! 🍕 Want a 2-minute recap?"',
    '"You\'re close to a new badge in Science — one more experiment to go!"',
    '"Try the Word Wizard game — it matches your English quest perfectly."',
    '"Studying in short 10-minute bursts helps memory stick. You\'ve got this!"',
  ];
  int _tipIndex = 0;

  // ---- Pet ---------------------------------------------------------
  double _petHunger = .55;
  String _petMood = 'Cheerful';

  bool get _allMissionsDone => _missions.every((m) => m.done);
  bool _chestOpened = false;

  @override
  Widget build(BuildContext context) => Theme(
        data: Class6Theme.theme,
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: AdventureColors.skyBottom,
            extendBody: true,
            bottomNavigationBar: const GradeBottomNav(color: AdventureColors.blue),
            body: ConfettiLayer(
              controller: _confetti,
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AdventureGradients.sky),
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                    children: [
                      HeroBanner(
                        name: _name,
                        level: _level,
                        streak: _streak,
                        xp: _xp,
                        xpTarget: _xpTarget,
                        coins: _coins,
                        onAvatarTap: () => _snack('Avatar wardrobe coming soon! 🎨'),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(emoji: '🎒', title: 'Continue Learning'),
                      const SizedBox(height: 12),
                      ContinueLearningSection(realms: Realm.all, onTapRealm: (r) => _snack('Jumping into ${r.name} realm ${r.emoji}')),
                      const SizedBox(height: 24),
                      DailyMissionsCard(missions: _missions, onToggle: _toggleMission),
                      const SizedBox(height: 20),
                      TreasureChest(
                        locked: !_allMissionsDone,
                        opened: _chestOpened,
                        rewardXp: 120,
                        rewardCoins: 50,
                        onOpen: _openChest,
                      ),
                      const SizedBox(height: 24),
                      AiBuddyCard(
                        tip: _tips[_tipIndex],
                        onChat: () => _snack('Opening chat with Zuzu... 💬'),
                        onNextTip: () => setState(() => _tipIndex = (_tipIndex + 1) % _tips.length),
                      ),
                      const SizedBox(height: 16),
                      PetCompanionCard(
                        petName: 'Blaze',
                        mood: _petMood,
                        hunger: _petHunger,
                        onFeed: _feedPet,
                        onPlay: _playWithPet,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(emoji: '🎮', title: 'Mini Learning Games'),
                      const SizedBox(height: 12),
                      MiniGamesGrid(onPlay: (g) => _snack('Launching ${g.title} ${g.emoji}')),
                      const SizedBox(height: 24),
                      _SectionTitle(emoji: '⭐', title: 'XP & Badges'),
                      const SizedBox(height: 12),
                      BadgeShelf(badges: _badges),
                      const SizedBox(height: 24),
                      WeeklyChallengeBanner(title: 'Explore 3 new Science realms', progress: .6, reward: '250 XP + Explorer Badge', daysLeft: 3),
                      const SizedBox(height: 24),
                      LeaderboardCard(rows: _leaderboard),
                      const SizedBox(height: 24),
                      AchievementCenter(badges: _achievements),
                      const SizedBox(height: 24),
                      UpcomingClassesCard(slots: _classSlots),
                      const SizedBox(height: 24),
                      WeeklyXpChart(values: const [.4, .6, .5, .8, .55, .35, .95], labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
                      const SizedBox(height: 24),
                      FunFactCard(fact: 'Octopuses have three hearts and blue blood! 🐙 Two hearts pump blood to the gills, one to the rest of the body.'),
                      const SizedBox(height: 24),
                      _SectionTitle(emoji: '🏰', title: 'Progress Castle'),
                      const SizedBox(height: 12),
                      ProgressCastle(realms: Realm.all, onTapRealm: (r) => _snack('${r.name} tower · ${(r.progress * 100).round()}% mastered')),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  // ---- Data -------------------------------------------------------------

  List<Badge_> get _badges => const [
        Badge_(icon: Icons.emoji_events_rounded, color: AdventureColors.yellowDeep, label: 'Star Reader'),
        Badge_(icon: Icons.bolt_rounded, color: AdventureColors.blue, label: 'Fast Learner'),
        Badge_(icon: Icons.local_fire_department_rounded, color: AdventureColors.orange, label: '5-Day Streak'),
        Badge_(icon: Icons.psychology_alt_rounded, color: AdventureColors.lime, label: 'Quiz Whiz'),
        Badge_(icon: Icons.explore_rounded, color: AdventureColors.blue, label: 'Realm Hopper', locked: true),
      ];

  List<Badge_> get _achievements => const [
        Badge_(icon: Icons.emoji_events_rounded, color: AdventureColors.yellowDeep, label: 'Star Reader'),
        Badge_(icon: Icons.bolt_rounded, color: AdventureColors.blue, label: 'Fast Learner'),
        Badge_(icon: Icons.local_fire_department_rounded, color: AdventureColors.orange, label: '5-Day Streak'),
        Badge_(icon: Icons.psychology_alt_rounded, color: AdventureColors.lime, label: 'Quiz Whiz'),
        Badge_(icon: Icons.calculate_rounded, color: AdventureColors.blue, label: 'Math Master', locked: true),
        Badge_(icon: Icons.science_rounded, color: AdventureColors.lime, label: 'Lab Legend', locked: true),
        Badge_(icon: Icons.public_rounded, color: AdventureColors.orange, label: 'World Explorer', locked: true),
        Badge_(icon: Icons.workspace_premium_rounded, color: AdventureColors.yellowDeep, label: 'Top of Class', locked: true),
      ];

  List<LeaderRow> get _leaderboard => const [
        LeaderRow(rank: 1, name: 'Isha', emoji: '👑', xp: 4120),
        LeaderRow(rank: 2, name: 'Aarav', emoji: '🦁', xp: 3980, isMe: true),
        LeaderRow(rank: 3, name: 'Kabir', emoji: '🐯', xp: 3760),
        LeaderRow(rank: 4, name: 'Meera', emoji: '🐼', xp: 3510),
        LeaderRow(rank: 5, name: 'Zoya', emoji: '🦊', xp: 3390),
      ];

  List<ClassSlot> get _classSlots => const [
        ClassSlot(time: 'Today · 4:00 PM', subject: 'Science Live Lab', emoji: '🔬', color: AdventureColors.lime, teacher: 'Ms. Rao'),
        ClassSlot(time: 'Today · 5:30 PM', subject: 'English Storytime', emoji: '📖', color: AdventureColors.yellowDeep, teacher: 'Mr. Sen'),
        ClassSlot(time: 'Tomorrow · 9:00 AM', subject: 'Math Challenge', emoji: '🧮', color: AdventureColors.blue, teacher: 'Mrs. Iyer'),
      ];

  // ---- Actions ------------------------------------------------------

  void _toggleMission(Mission m) {
    setState(() {
      m.done = !m.done;
      _xp += m.done ? m.xp : -m.xp;
    });
    if (_allMissionsDone) {
      _confetti.burst(at: const Offset(.5, .55));
      _snack('All missions complete! The Treasure Chest is unlocked 🎉');
    }
  }

  void _openChest() {
    setState(() {
      _chestOpened = true;
      _xp += 120;
      _coins += 50;
    });
    _confetti.burst(at: const Offset(.5, .45), count: 60);
  }

  void _feedPet() {
    setState(() {
      _petHunger = (_petHunger + .2).clamp(0.0, 1.0);
      _petMood = _petHunger > .8 ? 'Delighted' : 'Cheerful';
    });
    _snack('Blaze munches happily! 🍖');
  }

  void _playWithPet() {
    setState(() => _petMood = 'Excited');
    _confetti.burst(at: const Offset(.2, .6), count: 24);
    _snack('Blaze does a happy dance! 🎊');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, backgroundColor: AdventureColors.ink, duration: const Duration(milliseconds: 1400)));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.emoji, required this.title});
  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 19)),
        const SizedBox(width: 8),
        Text(title, style: AdventureText.h2),
      ]);
}
