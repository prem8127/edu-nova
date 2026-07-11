# EduNova — Scaffold

Flutter + Riverpod + GoRouter, local persistence (SharedPreferences) behind
repository interfaces so a real backend can swap in later with minimal
changes.

## Structure

```
lib/
  core/
    constants/app_enums.dart      # UserRole, Grade, Subject, CourseAccess
    theme/app_theme.dart          # one clean/strict theme for ALL grades
    router/app_router.dart        # GoRouter + auth/onboarding redirects
  models/                         # AppUser, CourseModel, QuizModel,
                                   # ScheduledClass, DoubtThread/Message
  services/
    interfaces/                   # UserRepository, CourseRepository,
                                   # QuizRepository, ScheduleRepository,
                                   # DoubtChatRepository  <- the contracts
    local/                        # LocalStorageService + Local*Repository
                                   # implementations of the above
  providers/
    repository_providers.dart     # ⭐ THE SWAP POINT — see below
    auth_provider.dart             # current user, onboarding, login/logout
    course_provider.dart           # listing, subject filter, paywall unlock
    progress_provider.dart         # lagging-area tracker (per-subject avg)
    calendar_provider.dart         # student calendar + teacher scheduling
    doubt_chat_provider.dart       # 1:1 thread creation + messaging
    admin_provider.dart            # Super Admin: add/remove teacher, stats
  screens/
    onboarding/   role_select_screen.dart, onboarding_screen.dart
    student/      dashboard, courses, course_detail, quiz, calendar,
                  doubt_chat, profile
    teacher/      dashboard, assigned_courses, start_class, doubt_chat_list
    admin/        admin_dashboard, manage_teachers
    shared/       app_bottom_nav.dart, doubt_thread_screen.dart
```

## The swap point

Every screen/provider depends on the *interface* types
(`UserRepository`, `CourseRepository`, etc.), never the `Local*`
implementations directly. `providers/repository_providers.dart` is the
only file that wires interface → implementation:

```dart
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return LocalUserRepository(); // swap for SupabaseUserRepository later
});
```

To move to a real backend: write `Supabase*Repository implements *Repository`
for each domain, change the 5 lines in that file. No screen or provider
changes.

## Changes in this pass (UI overhaul + demo data)

- **Dead code removed**: `lib/features/*` (an entire disconnected earlier
  prototype — auth/courses/explore/grades/mentor/profile/two alt app
  shells), `lib/data/*`, `lib/shared/widgets/ui.dart` (only used by the
  dead tree), a corrupted `lib/{core/...}` folder left by a bad shell
  command, and the stale `lib/app.dart` (referenced a non-existent
  `appRouter` — would not compile if anything had imported it). None of
  this was reachable from `main.dart`; removing it doesn't change any
  behavior.
- **Login rebuilt** (`role_select_screen.dart`): gradient hero header,
  role tabs (Student / Teacher / Admin) instead of stacked buttons,
  styled email/password fields, social sign-in row (decorative —
  explicitly "coming soon", no backend yet), forgot-password link. Signing
  in as Teacher now picks one of the *seeded* teacher accounts (by
  subject) instead of a throwaway random id — so the teacher dashboard
  actually has assigned courses and classes to show.
- **Profile rebuilt**: gradient header with avatar, stats row (courses
  enrolled, day streak, average score), a full per-subject progress
  breakdown (not just lagging ones), account details, settings sheet,
  and a confirm-before-logout dialog.
- **Home dashboard enhanced**: overall-progress ring card, a streak
  badge, a horizontally-scrolling "Continue learning" row (real enrolled
  courses with per-course completion bars), and a full subject-by-subject
  progress section (badges: Great / On track / Lagging) — the old
  "only show subjects that are lagging" section is now one part of this,
  not the whole progress story.
- **Demo data service** (`services/local/seed_data_service.dart`):
  - On first launch, seeds courses (every grade × subject), one teacher
    per subject with a fixed id, one quiz per course with real
    subject-appropriate questions, and a past + upcoming class per course
    — idempotent, skipped if courses already exist.
  - Right after a student finishes onboarding, seeds *their* purchased
    courses, a deliberately uneven quiz-attempt history (so the lagging
    tracker has something real to show on first login), and one open
    doubt-chat thread with a starter exchange.
  - `main.dart` now gates the first frame behind a splash screen tied to
    the platform seeding step, so nothing flashes an empty UI.
- Fixed a genuinely broken `test/widget_test.dart` (it imported a
  nonexistent `package:edu_guide/app.dart` and asserted on text that
  didn't exist anywhere in the app — it could never have passed).

## Previous pass

- **1-hour classes**: `ScheduledClass.durationMinutes` (default 60) +
  `endTime`/`hasEnded` getters. Calendar and admin class views now show
  duration and use `hasEnded` instead of raw start-time comparisons.
- **Paid-by-default courses**: removed the redundant `isPaywalled` flag.
  A course now requires purchase whenever `price > 0`
  (`CourseModel.requiresPurchase`); `price == 0` is the only way to make
  something free. Set every seeded course's price > 0 to match "each
  course must be bought."
- **Post-class doubt chat gating**: `hasCourseHadClassProvider` checks
  whether any scheduled class for a course has `hasEnded`; the "Ask a
  doubt" tile on course detail is locked (with an explanatory subtitle)
  until that's true.
- **Admin monitoring ("full visibility")**: two new screens —
  `student_progress_list_screen.dart` (every student, sorted by how many
  subjects they're lagging in, tap through to per-subject detail) and
  `platform_classes_screen.dart` (every scheduled class across every
  teacher/course, with completed/upcoming status). Both reuse the same
  `SubjectProgress`/`laggingThreshold` logic the student dashboard uses —
  one calculation, two consumers — via `progress_provider.dart`'s new
  student-id-generic providers.

## What's stubbed / not yet built

- **Course/quiz/teacher seed data** — there's no seeding yet, so screens
  will render empty states until courses/quizzes/teachers exist in
  storage (via the admin "add teacher" flow + a course-authoring screen,
  which isn't built yet).
- **Course-tied game** — `CourseModel.gameId` and the course detail entry
  point exist; the actual game screen is a TODO.
- **Payment gateway** — `purchaseCourse()` just flips a local "purchased"
  flag; swap in Razorpay/Stripe at that call site once decided.
- **Teacher class scheduling UI** — `ScheduleRepository` supports
  create/update; there's no "schedule a new class" form yet, only the
  Zoom-link-and-start flow for classes that already exist.
- **Login** — role-select screen creates a throwaway local
  teacher/admin account for now (no real auth). Student flow goes through
  proper onboarding.

## Run it

```
flutter pub get
flutter run
```
