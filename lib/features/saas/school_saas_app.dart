import 'dart:math' as math;

import 'package:flutter/material.dart';

enum UserRole { superAdmin, teacher }

enum ModuleId {
  dashboard,
  classWorkspace,
  curriculum,
  revenue,
  teachers,
  students,
  parents,
  classes,
  sections,
  subjects,
  assignments,
  attendance,
  exams,
  marks,
  timetable,
  homework,
  fees,
  announcements,
  events,
  reports,
  roles,
  files,
  leave,
  settings,
  logs,
  backup,
}

class SchoolSaasApp extends StatefulWidget {
  const SchoolSaasApp({super.key, this.onExit, this.initialRole = UserRole.superAdmin});
  final VoidCallback? onExit;
  final UserRole initialRole;

  @override
  State<SchoolSaasApp> createState() => _SchoolSaasAppState();
}

class _SchoolSaasAppState extends State<SchoolSaasApp> {
  bool dark = true;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aditya Globals',
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: _SaasTheme.light,
        darkTheme: _SaasTheme.dark,
        home: SaaSWorkspace(
          dark: dark,
          onThemeChanged: (value) => setState(() => dark = value),
          onExit: widget.onExit,
          initialRole: widget.initialRole,
        ),
      );
}

class SaaSWorkspace extends StatefulWidget {
  const SaaSWorkspace({super.key, required this.dark, required this.onThemeChanged, this.onExit, this.initialRole = UserRole.superAdmin});
  final bool dark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback? onExit;
  final UserRole initialRole;

  @override
  State<SaaSWorkspace> createState() => _SaaSWorkspaceState();
}

class _SaaSWorkspaceState extends State<SaaSWorkspace> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late UserRole role = widget.initialRole;
  ModuleId module = ModuleId.dashboard;
  String className = 'Grade 10 - A';
  bool loading = false;
  String toast = '';
  int page = 1;
  final selectedRows = <int>{};

  List<_Module> get visibleModules => _modules.where((m) => role == UserRole.superAdmin || m.teacher).toList();

  void selectModule(ModuleId next) {
    setState(() {
      module = next;
      loading = true;
      selectedRows.clear();
      page = 1;
    });
    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) setState(() => loading = false);
    });
  }

  void showToast(String message) {
    setState(() => toast = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && toast == message) setState(() => toast = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 860;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: narrow ? 60 : 0,
      drawer: narrow
          ? Drawer(
              width: 314,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: _SideNav(
                modules: visibleModules,
                selected: module,
                role: role,
                onSelect: (id) {
                  Navigator.of(context).pop();
                  selectModule(id);
                },
              ),
            )
          : null,
      body: Stack(
        children: [
          const _AuroraBackground(),
          Row(
            children: [
              if (!narrow)
                _SideNav(
                  modules: visibleModules,
                  selected: module,
                  role: role,
                  onSelect: selectModule,
                ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      _TopBar(
                        role: role,
                        dark: widget.dark,
                        module: _moduleTitle(module),
                        className: className,
                        onMenu: narrow ? () => _scaffoldKey.currentState?.openDrawer() : null,
                        onRole: (value) => setState(() {
                          role = value;
                          module = ModuleId.dashboard;
                        }),
                        onTheme: widget.onThemeChanged,
                        onClass: (value) => setState(() => className = value),
                        onToast: showToast,
                        onExit: widget.onExit,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: loading
                              ? const _SkeletonPage(key: ValueKey('loader'))
                              : _PageHost(
                                  key: ValueKey('${role.name}-${module.name}-$className-$page'),
                                  role: role,
                                  module: module,
                                  className: className,
                                  page: page,
                                  selectedRows: selectedRows,
                                  onPage: (value) => setState(() => page = value),
                                  onToggleRow: (value) => setState(() {
                                    selectedRows.contains(value) ? selectedRows.remove(value) : selectedRows.add(value);
                                  }),
                                  onToast: showToast,
                                  onOpenClass: () => selectModule(ModuleId.classWorkspace),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 22,
            bottom: narrow ? 92 : 24,
            child: AnimatedSlide(
              offset: toast.isEmpty ? const Offset(0, 1.2) : Offset.zero,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: toast.isEmpty ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                child: Material(
                  color: colors.inverseSurface,
                  elevation: 18,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, color: colors.primary),
                      const SizedBox(width: 10),
                      Text(toast, style: TextStyle(color: colors.onInverseSurface, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: narrow
          ? FloatingActionButton.extended(
              onPressed: () => showToast('Quick create opened'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create'),
            )
          : null,
    );
  }
}

class _PageHost extends StatelessWidget {
  const _PageHost({
    super.key,
    required this.role,
    required this.module,
    required this.className,
    required this.page,
    required this.selectedRows,
    required this.onPage,
    required this.onToggleRow,
    required this.onToast,
    required this.onOpenClass,
  });

  final UserRole role;
  final ModuleId module;
  final String className;
  final int page;
  final Set<int> selectedRows;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onToggleRow;
  final ValueChanged<String> onToast;
  final VoidCallback onOpenClass;

  @override
  Widget build(BuildContext context) {
    if (module == ModuleId.dashboard) return DashboardPage(role: role, className: className, onToast: onToast, onOpenClass: onOpenClass);
    if (module == ModuleId.classWorkspace) return ClassWorkspacePage(className: className, role: role, onToast: onToast);
    if (module == ModuleId.curriculum) return CurriculumPage(role: role, onToast: onToast);
    if (module == ModuleId.revenue) return RevenuePage(role: role, onToast: onToast);
    if (module == ModuleId.teachers) return TeachersPage(onToast: onToast);
    if (module == ModuleId.settings || module == ModuleId.roles || module == ModuleId.logs || module == ModuleId.backup) {
      return GovernancePage(module: module, role: role, onToast: onToast);
    }
    return ManagementPage(
      module: module,
      role: role,
      className: className,
      page: page,
      selectedRows: selectedRows,
      onPage: onPage,
      onToggleRow: onToggleRow,
      onToast: onToast,
      onOpenClass: onOpenClass,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.role, required this.className, required this.onToast, required this.onOpenClass});
  final UserRole role;
  final String className;
  final ValueChanged<String> onToast;
  final VoidCallback onOpenClass;

  @override
  Widget build(BuildContext context) {
    final admin = role == UserRole.superAdmin;
    final compact = MediaQuery.sizeOf(context).width < 720;
    return ListView(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 24, 8, compact ? 14 : 24, compact ? 112 : 28),
      children: [
        _DashboardHero(admin: admin, className: className, onToast: onToast, onOpenClass: onOpenClass),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 980 ? 4 : constraints.maxWidth > 620 ? 2 : 1;
          return _MetricGrid(columns: columns, metrics: admin ? _adminMetrics : _teacherMetrics);
        }),
        const SizedBox(height: 22),
        _ResponsiveGrid(
          left: _Panel(
            title: 'Enrollment & Attendance',
            action: 'View analytics',
            onAction: () => onToast('Analytics drill-down opened'),
            child: const SizedBox(height: 260, child: _BarChart(values: [82, 91, 88, 94, 86, 97, 90], labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])),
          ),
          right: _Panel(
            title: admin ? 'Fee Collection' : 'Class Health',
            action: 'Inspect',
            onAction: onOpenClass,
            child: Column(children: [
              const SizedBox(height: 12),
              _DonutSummary(value: admin ? .84 : .91, label: admin ? 'Collected' : 'On track', detail: admin ? '₹42.8L of ₹51L this term' : '36 of 40 students active this week'),
              const SizedBox(height: 18),
              _MiniInsight(icon: Icons.trending_up_rounded, title: admin ? 'Revenue up 12.4%' : 'Homework completion up 9%', color: const Color(0xFF22C55E)),
              _MiniInsight(icon: Icons.warning_amber_rounded, title: admin ? '18 fee reminders due' : '4 students need attendance review', color: const Color(0xFFF59E0B)),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        _ResponsiveGrid(
          left: _Panel(
            title: admin ? 'Operations Queue' : 'Today’s Teaching Plan',
            child: Column(children: (admin ? _adminQueue : _teacherQueue).map((item) => _TaskTile(item: item, onTap: () => onToast('${item.title} opened'))).toList()),
          ),
          right: _Panel(
            title: 'Class Workspaces',
            action: 'Open',
            onAction: onOpenClass,
            child: Column(children: _classWorkspaces.map((item) => _ClassWorkspaceTile(item: item, onTap: onOpenClass)).toList()),
          ),
        ),
      ],
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.admin, required this.className, required this.onToast, required this.onOpenClass});
  final bool admin;
  final String className;
  final ValueChanged<String> onToast;
  final VoidCallback onOpenClass;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 820;
    final title = admin ? 'Run every school system from one command layer.' : 'Teach from a workspace that already knows your day.';
    final subtitle = admin
        ? 'A cinematic ERP cockpit for people, classes, fees, exams, reports, permissions, logs, and recovery. Every class is isolated. Every action is auditable.'
        : '$className brings attendance, marks, homework, exams, files, notices, reports, and student profiles into one calm teaching surface.';
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 560 : 650),
      padding: EdgeInsets.all(compact ? 22 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 30 : 42),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF020617), Color(0xFF111827), Color(0xFF172554), Color(0xFF4C1D95)],
        ),
        border: Border.all(color: Colors.white24),
        boxShadow: [BoxShadow(color: const Color(0xFF020617).withValues(alpha: .38), blurRadius: 60, offset: const Offset(0, 28))],
      ),
      child: Stack(children: [
        const Positioned.fill(child: _HeroConstellation()),
        Positioned(
          right: compact ? -90 : -40,
          top: compact ? -70 : -40,
          child: Container(
            width: compact ? 230 : 360,
            height: compact ? 230 : 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [const Color(0xFF38BDF8).withValues(alpha: .28), Colors.transparent]),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _HeroPill(icon: Icons.verified_rounded, label: admin ? 'SUPER ADMIN OS' : 'TEACHER OS'),
            const SizedBox(width: 10),
            if (!compact) const _HeroPill(icon: Icons.lock_rounded, label: 'CLASS-ISOLATED DATA'),
            const Spacer(),
            if (!compact) _HeroStatus(onTap: () => onToast('Live system status opened')),
          ]),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 48 : 82,
                height: .92,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .72), fontSize: compact ? 16 : 19, height: 1.55, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 30),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _HeroButton(primary: true, icon: Icons.play_arrow_rounded, label: admin ? 'Open command center' : 'Start teaching day', onTap: onOpenClass),
            _HeroButton(primary: false, icon: Icons.analytics_rounded, label: 'View live reports', onTap: () => onToast('Live reports opened')),
            _HeroButton(primary: false, icon: Icons.file_download_rounded, label: 'Export board pack', onTap: () => onToast('PDF and Excel board pack generated')),
          ]),
          SizedBox(height: compact ? 30 : 46),
          LayoutBuilder(builder: (context, constraints) {
            final cards = admin
                ? const [
                    ('2,846', 'students synchronized', Icons.groups_rounded),
                    ('94.8%', 'attendance today', Icons.fact_check_rounded),
                    ('42.8L', 'fees collected', Icons.payments_rounded),
                  ]
                : const [
                    ('156', 'assigned students', Icons.groups_rounded),
                    ('4', 'classes today', Icons.meeting_room_rounded),
                    ('18', 'homework reviews', Icons.assignment_rounded),
                  ];
            if (constraints.maxWidth < 720) {
              return Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _HeroDataCard(value: card.$1, label: card.$2, icon: card.$3))).toList());
            }
            return Row(children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: _HeroDataCard(value: card.$1, label: card.$2, icon: card.$3)))).toList());
          }),
        ]),
      ]),
    );
  }
}

class _HeroConstellation extends StatelessWidget {
  const _HeroConstellation();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _HeroConstellationPainter(), child: const SizedBox.expand());
}

class _HeroConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..strokeWidth = 1;
    final dot = Paint()..color = Colors.white.withValues(alpha: .32);
    final points = [
      Offset(size.width * .56, size.height * .18),
      Offset(size.width * .78, size.height * .28),
      Offset(size.width * .68, size.height * .46),
      Offset(size.width * .9, size.height * .58),
      Offset(size.width * .62, size.height * .72),
    ];
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], line);
    }
    for (final p in points) {
      canvas.drawCircle(p, 4, dot);
      canvas.drawCircle(p, 12, Paint()..color = Colors.white.withValues(alpha: .05));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white.withValues(alpha: .14))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 7), Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))]),
      );
}

class _HeroStatus extends StatelessWidget {
  const _HeroStatus({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Icon(Icons.circle, color: Color(0xFF22C55E), size: 10),
              SizedBox(width: 8),
              Text('Live operations: 99.98%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.primary, required this.icon, required this.label, required this.onTap});
  final bool primary;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: primary ? Colors.white : Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: primary ? const Color(0xFF020617) : Colors.white),
              const SizedBox(width: 9),
              Text(label, style: TextStyle(color: primary ? const Color(0xFF020617) : Colors.white, fontWeight: FontWeight.w900)),
            ]),
          ),
        ),
      );
}

class _HeroDataCard extends StatelessWidget {
  const _HeroDataCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .16)),
        ),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .64), fontWeight: FontWeight.w700))])),
        ]),
      );
}

class ManagementPage extends StatelessWidget {
  const ManagementPage({
    super.key,
    required this.module,
    required this.role,
    required this.className,
    required this.page,
    required this.selectedRows,
    required this.onPage,
    required this.onToggleRow,
    required this.onToast,
    required this.onOpenClass,
  });

  final ModuleId module;
  final UserRole role;
  final String className;
  final int page;
  final Set<int> selectedRows;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onToggleRow;
  final ValueChanged<String> onToast;
  final VoidCallback onOpenClass;

  @override
  Widget build(BuildContext context) {
    final data = _rowsFor(module, role, className);
    final headers = _headersFor(module);
    final title = _moduleTitle(module);
    final classScoped = role == UserRole.teacher || _classScopedModules.contains(module);
    return _PageScaffold(
      title: title,
      subtitle: classScoped ? '$title for $className. Data is isolated inside this class workspace.' : 'Enterprise CRUD, filters, pagination, bulk actions, imports, and exports.',
      actions: [
        if (role == UserRole.superAdmin) _ActionChipButton(icon: Icons.add_rounded, label: 'Create', onTap: () => onToast('Create $title dialog opened')),
        _ActionChipButton(icon: Icons.file_download_rounded, label: 'Excel', onTap: () => onToast('$title Excel export ready')),
        _ActionChipButton(icon: Icons.picture_as_pdf_rounded, label: 'PDF', onTap: () => onToast('$title PDF report ready')),
      ],
      child: Column(children: [
        _Toolbar(
          module: module,
          selected: selectedRows.length,
          onToast: onToast,
          onOpenClass: classScoped ? onOpenClass : null,
        ),
        const SizedBox(height: 14),
        _DataPanel(
          headers: headers,
          rows: data,
          selectedRows: selectedRows,
          onToggleRow: onToggleRow,
          onAction: (action, row) => onToast('$action ${row.first}'),
        ),
        const SizedBox(height: 12),
        _Pagination(page: page, total: 8, onPage: onPage),
      ]),
    );
  }
}

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key, required this.onToast});
  final ValueChanged<String> onToast;

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final teachers = _seedTeachers();

  Future<void> _openAddTeacher() async {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add teacher'),
        content: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: 'Assigned grade(s)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add teacher')),
        ],
      ),
    );
    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      setState(() {
        teachers.add(_TeacherProfile(
          name: nameCtrl.text.trim(),
          subject: subjectCtrl.text.trim().isEmpty ? 'Unassigned' : subjectCtrl.text.trim(),
          grades: gradeCtrl.text.trim().isEmpty ? 'Not assigned' : gradeCtrl.text.trim(),
          status: 'Pending approval',
          students: 0,
          revenue: 0,
          rating: 0,
        ));
      });
      widget.onToast('${nameCtrl.text.trim()} invited as a teacher');
    }
  }

  void _toggleStatus(_TeacherProfile teacher) {
    setState(() => teacher.status = teacher.status == 'Active' ? 'Suspended' : 'Active');
    widget.onToast('${teacher.name} marked ${teacher.status}');
  }

  @override
  Widget build(BuildContext context) => _PageScaffold(
        title: 'Teachers',
        subtitle: 'Onboard teachers, assign subjects and grades, and manage their access.',
        actions: [
          _ActionChipButton(icon: Icons.person_add_alt_1_rounded, label: 'Add teacher', onTap: _openAddTeacher),
          _ActionChipButton(icon: Icons.file_download_rounded, label: 'Excel', onTap: () => widget.onToast('Teacher list exported')),
        ],
        child: LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 980 ? 3 : constraints.maxWidth > 620 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 1.35),
            itemCount: teachers.length,
            itemBuilder: (context, i) {
              final t = teachers[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: _glassDecoration(context, radius: 26),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 24, backgroundColor: _avatarColor(i), child: Text(t.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                      Text(t.subject, style: Theme.of(context).textTheme.bodySmall),
                    ])),
                    StatusPillMini(label: t.status),
                  ]),
                  const SizedBox(height: 14),
                  Text(t.grades, style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Row(children: [
                    Expanded(child: _MiniStat(icon: Icons.groups_rounded, value: '${t.students}', label: 'Students')),
                    Expanded(child: _MiniStat(icon: Icons.payments_rounded, value: '₹${(t.revenue / 1000).toStringAsFixed(1)}k', label: 'Revenue')),
                    Expanded(child: _MiniStat(icon: Icons.star_rounded, value: t.rating == 0 ? '-' : t.rating.toStringAsFixed(1), label: 'Rating')),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => widget.onToast('Opening ${t.name}\'s curriculum'), child: const Text('View curriculum'))),
                    const SizedBox(width: 8),
                    _TinyIcon(icon: t.status == 'Active' ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, onTap: () => _toggleStatus(t)),
                  ]),
                ]),
              );
            },
          );
        }),
      );
}

class StatusPillMini extends StatelessWidget {
  const StatusPillMini({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = label == 'Active' ? const Color(0xFF22C55E) : label == 'On Leave' ? const Color(0xFFF59E0B) : label == 'Pending approval' ? const Color(0xFF7C3AED) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}

class CurriculumPage extends StatefulWidget {
  const CurriculumPage({super.key, required this.role, required this.onToast});
  final UserRole role;
  final ValueChanged<String> onToast;

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  final subjects = _seedCurriculum();
  int selected = 0;

  Future<void> _addChapter() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add chapter'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Chapter title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      setState(() => subjects[selected].chapters.add(_CurriculumChapter(title: ctrl.text.trim(), lessons: [])));
      widget.onToast('Chapter "${ctrl.text.trim()}" added');
    }
  }

  Future<void> _addLesson(_CurriculumChapter chapter) async {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '15 min');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add recorded lesson'),
        content: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Lesson title')),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Video duration')),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_rounded), label: const Text('Upload recorded video')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add lesson')),
        ],
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      setState(() => chapter.lessons.add(_CurriculumLesson(title: titleCtrl.text.trim(), duration: durationCtrl.text.trim())));
      widget.onToast('Lesson "${titleCtrl.text.trim()}" added');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = subjects[selected];
    final admin = widget.role == UserRole.superAdmin;
    return _PageScaffold(
      title: 'Curriculum & Lessons',
      subtitle: admin ? 'Every subject\'s syllabus and recorded sections across the platform.' : 'Build your syllabus: chapters, and the recorded video sections inside them.',
      actions: [
        _ActionChipButton(icon: Icons.add_rounded, label: 'Add chapter', onTap: _addChapter),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _SegmentButton(label: '${subjects[i].subject} · ${subjects[i].grade}', selected: selected == i, onTap: () => setState(() => selected = i)),
          ),
        ),
        const SizedBox(height: 8),
        Text('Taught by ${subject.teacher} · ${subject.lessonCount} recorded lessons', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 18),
        for (final chapter in subject.chapters)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: _glassDecoration(context, radius: 22),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
              title: Text(chapter.title, style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text('${chapter.lessons.length} recorded sections'),
              children: [
                for (final lesson in chapter.lessons)
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.play_circle_fill_rounded)),
                    title: Text(lesson.title),
                    subtitle: Text(lesson.duration),
                    trailing: StatusPillMini(label: lesson.published ? 'Published' : 'Draft'),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: OutlinedButton.icon(onPressed: () => _addLesson(chapter), icon: const Icon(Icons.videocam_rounded), label: const Text('Add recorded lesson')),
                ),
              ],
            ),
          ),
      ]),
    );
  }
}

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key, required this.role, required this.onToast});
  final UserRole role;
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) {
    final admin = role == UserRole.superAdmin;
    final total = _topCourseRevenue.fold(0.0, (sum, s) => sum + s.value);
    return _PageScaffold(
      title: admin ? 'Platform Revenue' : 'My Earnings',
      subtitle: admin ? 'Revenue across every teacher, course, and grade on the platform.' : 'Your earnings from enrolled students across your courses.',
      actions: [
        _ActionChipButton(icon: Icons.file_download_rounded, label: 'Statement', onTap: () => onToast('Revenue statement exported')),
      ],
      child: Column(children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 980 ? 4 : constraints.maxWidth > 620 ? 2 : 1;
          return _MetricGrid(columns: columns, metrics: [
            _Metric(admin ? 'Total Revenue' : 'Your Revenue', '₹${(total / 1000).toStringAsFixed(1)}k', '+12.4%', Icons.payments_rounded, const Color(0xFF2563EB)),
            _Metric('Paying Students', admin ? '2,846' : '156', '+8.2%', Icons.groups_rounded, const Color(0xFF059669)),
            _Metric(admin ? 'Active Teachers' : 'Active Courses', admin ? '${_seedTeachers().where((t) => t.status == 'Active').length}' : '4', '+1', Icons.co_present_rounded, const Color(0xFFEA580C)),
            _Metric('Payout Due', admin ? '₹18.2k' : '₹6.4k', 'Next: 5 Jul', Icons.account_balance_wallet_rounded, const Color(0xFF7C3AED)),
          ]);
        }),
        const SizedBox(height: 22),
        _ResponsiveGrid(
          left: _Panel(
            title: 'Revenue trend',
            action: 'View details',
            onAction: () => onToast('Revenue analytics opened'),
            child: SizedBox(height: 260, child: _BarChart(values: _revenueTrend, labels: _revenueTrendLabels)),
          ),
          right: _Panel(
            title: admin ? 'Top earning courses' : 'Your courses by earnings',
            child: Column(children: [
              for (final slice in _topCourseRevenue)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(slice.label, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)),
                    Text('₹${(slice.value / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                ),
            ]),
          ),
        ),
        if (admin) ...[
          const SizedBox(height: 22),
          _Panel(
            title: 'Revenue by teacher',
            child: Column(children: [
              for (final t in _seedTeachers().where((t) => t.revenue > 0))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    CircleAvatar(radius: 14, backgroundColor: _avatarColor(t.name.length), child: Text(t.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t.name, style: Theme.of(context).textTheme.bodyMedium)),
                    Text('₹${(t.revenue / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class ClassWorkspacePage extends StatefulWidget {
  const ClassWorkspacePage({super.key, required this.className, required this.role, required this.onToast});
  final String className;
  final UserRole role;
  final ValueChanged<String> onToast;

  @override
  State<ClassWorkspacePage> createState() => _ClassWorkspacePageState();
}

class _ClassWorkspacePageState extends State<ClassWorkspacePage> {
  int tab = 0;
  static const tabs = ['Overview', 'Students', 'Attendance', 'Marks', 'Timetable', 'Homework', 'Exams', 'Files', 'Announcements', 'Reports'];

  @override
  Widget build(BuildContext context) => _PageScaffold(
        title: widget.className,
        subtitle: 'Isolated workspace with separate learners, attendance, marks, timetable, homework, exams, files, announcements, and reports.',
        actions: [
          _ActionChipButton(icon: Icons.lock_rounded, label: 'Isolated', onTap: () => widget.onToast('Class-level isolation verified')),
          _ActionChipButton(icon: Icons.share_rounded, label: 'Share', onTap: () => widget.onToast('Workspace summary shared')),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => _SegmentButton(label: tabs[i], selected: tab == i, onTap: () => setState(() => tab = i)),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: tabs.length,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: tab == 0
                ? _ClassOverview(key: const ValueKey('overview'), onToast: widget.onToast)
                : _DataPanel(
                    key: ValueKey(tab),
                    headers: _workspaceHeaders[tabs[tab]]!,
                    rows: _workspaceRows(tabs[tab]),
                    selectedRows: const {},
                    onToggleRow: (_) {},
                    onAction: (action, row) => widget.onToast('$action ${row.first}'),
                  ),
          ),
        ]),
      );
}

class GovernancePage extends StatelessWidget {
  const GovernancePage({super.key, required this.module, required this.role, required this.onToast});
  final ModuleId module;
  final UserRole role;
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) {
    final title = _moduleTitle(module);
    return _PageScaffold(
      title: title,
      subtitle: module == ModuleId.roles
          ? 'Granular access control for Super Admin and Teacher roles.'
          : module == ModuleId.backup
              ? 'Encrypted backup, restore points, and exportable recovery logs.'
              : module == ModuleId.logs
                  ? 'Auditable activity logs with actor, module, device, and timestamp.'
                  : 'Institution profile, academic year, billing, security, notifications, and data policies.',
      actions: [_ActionChipButton(icon: Icons.save_rounded, label: 'Save', onTap: () => onToast('$title saved'))],
      child: module == ModuleId.roles
          ? _PermissionMatrix(onToast: onToast)
          : module == ModuleId.backup
              ? _BackupPanel(onToast: onToast)
              : module == ModuleId.logs
                  ? _DataPanel(headers: const ['Actor', 'Module', 'Action', 'Device', 'Time'], rows: _activityRows, selectedRows: const {}, onToggleRow: (_) {}, onAction: (a, r) => onToast('$a ${r.first}'))
                  : _SettingsPanel(onToast: onToast),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.role,
    required this.dark,
    required this.module,
    required this.className,
    required this.onRole,
    required this.onTheme,
    required this.onClass,
    required this.onToast,
    this.onMenu,
    this.onExit,
  });

  final UserRole role;
  final bool dark;
  final String module;
  final String className;
  final ValueChanged<UserRole> onRole;
  final ValueChanged<bool> onTheme;
  final ValueChanged<String> onClass;
  final ValueChanged<String> onToast;
  final VoidCallback? onMenu;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    final narrow = MediaQuery.sizeOf(context).width < 860;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 22, 14, compact ? 14 : 24, 10),
      child: Row(children: [
        if (narrow && onMenu != null) ...[
          _IconCircle(icon: Icons.menu_rounded, onTap: onMenu!),
          const SizedBox(width: 10),
        ],
        if (compact) ...[
          _Brand(compact: true),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: _GlassField(
            child: Row(children: [
              const Icon(Icons.search_rounded, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Search $module, students, reports...', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)),
              if (!compact) const _ShortcutHint(),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        if (!compact)
          _PopupSelector<String>(
            icon: Icons.apartment_rounded,
            value: className,
            values: _classNames,
            onChanged: onClass,
          ),
        const SizedBox(width: 10),
        _PopupSelector<UserRole>(
          icon: Icons.admin_panel_settings_rounded,
          value: role,
          values: UserRole.values,
          label: (value) => value == UserRole.superAdmin ? 'Super Admin' : 'Teacher',
          onChanged: onRole,
        ),
        const SizedBox(width: 10),
        _IconCircle(icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, onTap: () => onTheme(!dark)),
        const SizedBox(width: 10),
        _IconCircle(icon: Icons.notifications_active_rounded, badge: true, onTap: () => onToast('5 priority notices opened')),
        if (onExit != null) ...[
          const SizedBox(width: 10),
          _IconCircle(icon: Icons.logout_rounded, onTap: onExit!),
        ],
      ]),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.modules, required this.selected, required this.role, required this.onSelect});
  final List<_Module> modules;
  final ModuleId selected;
  final UserRole role;
  final ValueChanged<ModuleId> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        width: 286,
        margin: const EdgeInsets.all(14),
        decoration: _glassDecoration(context, radius: 28),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(children: [
              const _Brand(),
              const Spacer(),
              _RolePill(role: role),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final group in _groups)
                  _NavGroup(
                    label: group,
                    modules: modules.where((m) => m.group == group).toList(),
                    selected: selected,
                    onSelect: onSelect,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: _UpgradeCard(onTap: () {}),
          ),
        ]),
      );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.modules, required this.selected, required this.onSelect});
  final List<_Module> modules;
  final ModuleId selected;
  final ValueChanged<ModuleId> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.all(8),
        decoration: _glassDecoration(context, radius: 24),
        child: Row(children: modules.map((m) {
          final active = selected == m.id;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(m.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: active ? Theme.of(context).colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                child: Icon(m.icon, color: active ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }).toList()),
      );
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({required this.title, required this.subtitle, required this.child, this.actions = const []});
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return ListView(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 24, 8, compact ? 14 : 24, compact ? 112 : 26),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 7),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          if (!compact) Wrap(spacing: 10, runSpacing: 10, children: actions),
        ]),
        if (compact && actions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.columns, required this.metrics});
  final int columns;
  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: columns == 1 ? 2.8 : 1.65),
        itemCount: metrics.length,
        itemBuilder: (_, i) => _MetricCard(metric: metrics[i], delay: i * 70),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.delay});
  final _Metric metric;
  final int delay;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 420 + delay),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Transform.translate(offset: Offset(0, 16 * (1 - value)), child: Opacity(opacity: value, child: child)),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: _glassDecoration(context, radius: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(gradient: LinearGradient(colors: [metric.color, metric.color.withValues(alpha: .55)]), borderRadius: BorderRadius.circular(18)), child: Icon(metric.icon, color: Colors.white)),
              const Spacer(),
              Text(metric.delta, style: TextStyle(color: metric.delta.startsWith('-') ? Colors.redAccent : const Color(0xFF22C55E), fontWeight: FontWeight.w900)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(metric.value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(metric.label, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ]),
        ),
      );
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 980) {
      return Column(children: [left, const SizedBox(height: 18), right]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 7, child: left), const SizedBox(width: 22), Expanded(flex: 4, child: right)]);
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: _glassDecoration(context, radius: 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.module, required this.selected, required this.onToast, this.onOpenClass});
  final ModuleId module;
  final int selected;
  final ValueChanged<String> onToast;
  final VoidCallback? onOpenClass;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: _glassDecoration(context, radius: 22),
        child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: 280,
            child: _GlassField(child: Row(children: [const Icon(Icons.search_rounded, size: 19), const SizedBox(width: 8), Expanded(child: Text('Search ${_moduleTitle(module)}', style: Theme.of(context).textTheme.bodyMedium))])),
          ),
          _ActionChipButton(icon: Icons.filter_list_rounded, label: 'Filters', onTap: () => onToast('Advanced filters opened')),
          _ActionChipButton(icon: Icons.sort_rounded, label: 'Sort', onTap: () => onToast('Sorting applied')),
          _ActionChipButton(icon: Icons.select_all_rounded, label: selected == 0 ? 'Bulk actions' : '$selected selected', onTap: () => onToast(selected == 0 ? 'Select rows to use bulk actions' : 'Bulk action menu opened')),
          if (onOpenClass != null) _ActionChipButton(icon: Icons.meeting_room_rounded, label: 'Class workspace', onTap: onOpenClass!),
        ]),
      );
}

class _DataPanel extends StatelessWidget {
  const _DataPanel({super.key, required this.headers, required this.rows, required this.selectedRows, required this.onToggleRow, required this.onAction});
  final List<String> headers;
  final List<List<String>> rows;
  final Set<int> selectedRows;
  final ValueChanged<int> onToggleRow;
  final void Function(String action, List<String> row) onAction;

  @override
  Widget build(BuildContext context) {
    final minWidth = math.max(760.0, 150.0 * headers.length);
    return Container(
      decoration: _glassDecoration(context, radius: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minWidth,
            child: Column(children: [
              Container(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  const SizedBox(width: 46),
                  for (final h in headers) Expanded(child: Text(h, style: Theme.of(context).textTheme.labelLarge)),
                  const SizedBox(width: 122, child: Text('Actions', textAlign: TextAlign.right)),
                ]),
              ),
              for (var i = 0; i < rows.length; i++)
                _DataRowTile(index: i, headers: headers, row: rows[i], selected: selectedRows.contains(i), onToggle: () => onToggleRow(i), onAction: onAction),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DataRowTile extends StatelessWidget {
  const _DataRowTile({required this.index, required this.headers, required this.row, required this.selected, required this.onToggle, required this.onAction});
  final int index;
  final List<String> headers;
  final List<String> row;
  final bool selected;
  final VoidCallback onToggle;
  final void Function(String action, List<String> row) onAction;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: .08) : Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .55)))),
            child: Row(children: [
              SizedBox(width: 46, child: Checkbox(value: selected, onChanged: (_) => onToggle())),
              for (var i = 0; i < headers.length; i++)
                Expanded(
                  child: i == 0
                      ? Row(children: [
                          CircleAvatar(radius: 16, backgroundColor: _avatarColor(index), child: Text(row[i].characters.first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                          const SizedBox(width: 9),
                          Expanded(child: Text(row[i], overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
                        ])
                      : Text(row.length > i ? row[i] : '', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                ),
              SizedBox(
                width: 122,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _TinyIcon(icon: Icons.edit_rounded, onTap: () => onAction('Edit', row)),
                  _TinyIcon(icon: Icons.visibility_rounded, onTap: () => onAction('View', row)),
                  _TinyIcon(icon: Icons.more_horiz_rounded, onTap: () => onAction('More actions for', row)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class _ClassOverview extends StatelessWidget {
  const _ClassOverview({super.key, required this.onToast});
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) => Column(children: [
        LayoutBuilder(builder: (context, constraints) => _MetricGrid(columns: constraints.maxWidth > 860 ? 4 : constraints.maxWidth > 540 ? 2 : 1, metrics: _classMetrics)),
        const SizedBox(height: 18),
        _ResponsiveGrid(
          left: _Panel(title: 'Attendance Trend', child: const SizedBox(height: 230, child: _BarChart(values: [96, 92, 98, 94, 91, 97, 95], labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S']))),
          right: _Panel(
            title: 'Workspace Actions',
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              _ActionChipButton(icon: Icons.how_to_reg_rounded, label: 'Mark attendance', onTap: () => onToast('Attendance sheet opened')),
              _ActionChipButton(icon: Icons.assignment_turned_in_rounded, label: 'Publish homework', onTap: () => onToast('Homework published')),
              _ActionChipButton(icon: Icons.grade_rounded, label: 'Enter marks', onTap: () => onToast('Marks entry opened')),
              _ActionChipButton(icon: Icons.campaign_rounded, label: 'Notify parents', onTap: () => onToast('Parent notice sent')),
            ]),
          ),
        ),
      ]);
}

class _PermissionMatrix extends StatelessWidget {
  const _PermissionMatrix({required this.onToast});
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) => _Panel(
        title: 'Role Permissions Matrix',
        child: Column(children: [
          _PermissionRow(module: 'People & Academics', admin: true, teacher: false),
          _PermissionRow(module: 'Assigned Classes', admin: true, teacher: true),
          _PermissionRow(module: 'Attendance & Marks', admin: true, teacher: true),
          _PermissionRow(module: 'Fees & Billing', admin: true, teacher: false),
          _PermissionRow(module: 'Reports Export', admin: true, teacher: true),
          _PermissionRow(module: 'Backup / Restore', admin: true, teacher: false),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: _ActionChipButton(icon: Icons.save_rounded, label: 'Apply permissions', onTap: () => onToast('Permissions updated'))),
        ]),
      );
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.onToast});
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) => _ResponsiveGrid(
        left: _Panel(
          title: 'Institution Settings',
          child: Column(children: [
            _SettingTile(icon: Icons.school_rounded, title: 'School profile', subtitle: 'EduCloud International School, CBSE, Hyderabad', onTap: () => onToast('School profile editor opened')),
            _SettingTile(icon: Icons.calendar_month_rounded, title: 'Academic year', subtitle: '2026-2027 with 4 exam terms', onTap: () => onToast('Academic calendar opened')),
            _SettingTile(icon: Icons.security_rounded, title: 'Security policy', subtitle: 'MFA required for admins, session timeout 30 min', onTap: () => onToast('Security policy opened')),
            _SettingTile(icon: Icons.notifications_rounded, title: 'Notification channels', subtitle: 'Email, SMS, push, WhatsApp-ready exports', onTap: () => onToast('Notifications configured')),
          ]),
        ),
        right: _Panel(
          title: 'System Health',
          child: Column(children: const [
            _HealthLine(label: 'API uptime', value: .998, detail: '99.8%'),
            _HealthLine(label: 'Storage used', value: .62, detail: '1.2 TB'),
            _HealthLine(label: 'Report queue', value: .28, detail: '14 jobs'),
          ]),
        ),
      );
}

class _BackupPanel extends StatelessWidget {
  const _BackupPanel({required this.onToast});
  final ValueChanged<String> onToast;

  @override
  Widget build(BuildContext context) => _ResponsiveGrid(
        left: _Panel(
          title: 'Backup & Restore',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DonutSummary(value: .76, label: 'Backup health', detail: 'Last verified restore: today, 04:12 AM'),
            const SizedBox(height: 18),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _ActionChipButton(icon: Icons.backup_rounded, label: 'Run backup', onTap: () => onToast('Encrypted backup started')),
              _ActionChipButton(icon: Icons.restore_rounded, label: 'Restore point', onTap: () => onToast('Restore point selected')),
              _ActionChipButton(icon: Icons.download_rounded, label: 'Download log', onTap: () => onToast('Backup log downloaded')),
            ]),
          ]),
        ),
        right: _Panel(title: 'Restore Points', child: Column(children: _backupRows.map((r) => _SimpleListLine(title: r[0], subtitle: '${r[1]} • ${r[2]}', icon: Icons.restore_page_rounded)).toList())),
      );
}

class _SkeletonPage extends StatelessWidget {
  const _SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SkeletonBox(width: 340, height: 34),
          const SizedBox(height: 10),
          _SkeletonBox(width: 560, height: 16),
          const SizedBox(height: 22),
          Wrap(spacing: 14, runSpacing: 14, children: List.generate(4, (_) => const _SkeletonBox(width: 240, height: 128))),
          const SizedBox(height: 18),
          const _SkeletonBox(width: double.infinity, height: 320),
        ],
      );
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.width, required this.height});
  final double width;
  final double height;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.lerp(Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface, controller.value),
          ),
        ),
      );
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels});
  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BarPainter(values, labels, Theme.of(context).colorScheme), child: const SizedBox.expand());
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.values, this.labels, this.scheme);
  final List<double> values;
  final List<String> labels;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.reduce(math.max);
    final paint = Paint()..strokeCap = StrokeCap.round;
    final grid = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: .6)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 20 + i * (size.height - 54) / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final step = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final barHeight = (size.height - 62) * values[i] / maxValue;
      final x = step * i + step / 2;
      final rect = Rect.fromLTWH(x - 12, size.height - 34 - barHeight, 24, barHeight);
      paint.shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scheme.primary, scheme.secondary]).createShader(rect);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);
      final text = TextPainter(text: TextSpan(text: labels[i], style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700)), textDirection: TextDirection.ltr)..layout();
      text.paint(canvas, Offset(x - text.width / 2, size.height - 22));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => false;
}

class _DonutSummary extends StatelessWidget {
  const _DonutSummary({required this.value, required this.label, required this.detail});
  final double value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: 116, height: 116, child: CustomPaint(painter: _DonutPainter(value, Theme.of(context).colorScheme), child: Center(child: Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.titleLarge)))),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), Text(detail, style: Theme.of(context).textTheme.bodyMedium)])),
      ]);
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.value, this.scheme);
  final double value;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..color = scheme.outlineVariant;
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(colors: [scheme.primary, scheme.secondary, scheme.primary]).createShader(rect);
    canvas.drawArc(rect.deflate(8), 0, math.pi * 2, false, base);
    canvas.drawArc(rect.deflate(8), -math.pi / 2, math.pi * 2 * value, false, active);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.value != value;
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 7), Text(label, style: const TextStyle(fontWeight: FontWeight.w800))]),
          ),
        ),
      );
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: selected ? Theme.of(context).colorScheme.onPrimary : null)),
          ),
        ),
      );
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.page, required this.total, required this.onPage});
  final int page;
  final int total;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(children: [
        Text('Showing ${((page - 1) * 12) + 1}-${math.min(page * 12, 96)} of 96 records', style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        _TinyIcon(icon: Icons.chevron_left_rounded, onTap: page > 1 ? () => onPage(page - 1) : null),
        for (final p in [1, 2, 3, 4])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _SegmentButton(label: '$p', selected: page == p, onTap: () => onPage(p)),
          ),
        _TinyIcon(icon: Icons.chevron_right_rounded, onTap: page < total ? () => onPage(page + 1) : null),
      ]);
}

class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.label, required this.modules, required this.selected, required this.onSelect});
  final String label;
  final List<_Module> modules;
  final ModuleId selected;
  final ValueChanged<ModuleId> onSelect;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 7),
        child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w900)),
      ),
      for (final m in modules)
        _NavItem(module: m, selected: selected == m.id, onTap: () => onSelect(m.id)),
    ]);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.module, required this.selected, required this.onTap});
  final _Module module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Material(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(children: [
                Icon(module.icon, size: 20, color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 11),
                Expanded(child: Text(module.title, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Theme.of(context).colorScheme.onPrimary : null))),
              ]),
            ),
          ),
        ),
      );
}

class _PopupSelector<T> extends StatelessWidget {
  const _PopupSelector({required this.icon, required this.value, required this.values, required this.onChanged, this.label});
  final IconData icon;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;
  final String Function(T value)? label;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
        tooltip: 'Change ${label?.call(value) ?? value}',
        onSelected: onChanged,
        itemBuilder: (_) => values.map((v) => PopupMenuItem(value: v, child: Text(label?.call(v) ?? '$v'))).toList(),
        child: _GlassField(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Text(label?.call(value) ?? '$value', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ]),
        ),
      );
}

class _GlassField extends StatelessWidget {
  const _GlassField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .7)),
        ),
        child: Center(child: child),
      );
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .76),
          shape: const CircleBorder(),
          child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, size: 21))),
        ),
        if (badge) Positioned(right: 3, top: 2, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle))),
      ]);
}

class _TinyIcon extends StatelessWidget {
  const _TinyIcon({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .68),
          shape: const CircleBorder(),
          child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 17))),
        ),
      );
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]), borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.school_rounded, color: Colors.white),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aditya Globals', style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1)),
            Text('Learning Platform', style: Theme.of(context).textTheme.labelSmall),
          ]),
        ],
      ]);
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final UserRole role;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(99)),
        child: Text(role == UserRole.superAdmin ? 'ADMIN' : 'TEACHER', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.w900)),
      );
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white),
              SizedBox(height: 12),
              Text('Enterprise ready', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('Audit trails, exports, permissions, and backups enabled.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        ),
      );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.item, required this.onTap});
  final _Task item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _SimpleListLine(icon: item.icon, title: item.title, subtitle: item.subtitle, trailing: item.time, onTap: onTap);
}

class _ClassWorkspaceTile extends StatelessWidget {
  const _ClassWorkspaceTile({required this.item, required this.onTap});
  final _ClassInfo item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _SimpleListLine(icon: Icons.meeting_room_rounded, title: item.name, subtitle: '${item.students} students • ${item.teacher}', trailing: '${item.attendance}%', onTap: onTap);
}

class _SimpleListLine extends StatelessWidget {
  const _SimpleListLine({required this.icon, required this.title, required this.subtitle, this.trailing, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])),
                if (trailing != null) Text(trailing!, style: const TextStyle(fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
        ),
      );
}

class _MiniInsight extends StatelessWidget {
  const _MiniInsight({required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => _SimpleListLine(icon: icon, title: title, subtitle: 'Updated just now', trailing: 'Live');
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.module, required this.admin, required this.teacher});
  final String module;
  final bool admin;
  final bool teacher;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(flex: 2, child: Text(module, style: const TextStyle(fontWeight: FontWeight.w900))),
          Expanded(child: Switch(value: admin, onChanged: (_) {})),
          Expanded(child: Switch(value: teacher, onChanged: (_) {})),
        ]),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _SimpleListLine(icon: icon, title: title, subtitle: subtitle, onTap: onTap);
}

class _HealthLine extends StatelessWidget {
  const _HealthLine({required this.label, required this.value, required this.detail});
  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), Text(detail, style: const TextStyle(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: value, minHeight: 9)),
        ]),
      );
}

class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
        child: const Text('Ctrl K', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
      );
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? const [Color(0xFF020617), Color(0xFF0B1120), Color(0xFF111827), Color(0xFF1E1B4B)] : const [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFFFF7ED)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(dark: dark), child: const SizedBox.expand()),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: dark ? .026 : .04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

BoxDecoration _glassDecoration(BuildContext context, {double radius = 20}) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: scheme.surface.withValues(alpha: dark ? .52 : .78),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: scheme.outlineVariant.withValues(alpha: dark ? .20 : .72)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .34 : .08), blurRadius: 38, offset: const Offset(0, 22))],
  );
}

Color _avatarColor(int i) => [const Color(0xFF2563EB), const Color(0xFF7C3AED), const Color(0xFF059669), const Color(0xFFEA580C), const Color(0xFFDB2777)][i % 5];

String _moduleTitle(ModuleId id) => _modules.firstWhere((m) => m.id == id).title;

List<String> _headersFor(ModuleId module) {
  switch (module) {
    case ModuleId.attendance:
      return const ['Student', 'Roll No', 'Status', 'Check-in', 'Remarks'];
    case ModuleId.marks:
      return const ['Student', 'Exam', 'Subject', 'Marks', 'Grade'];
    case ModuleId.timetable:
      return const ['Day', 'Period 1', 'Period 2', 'Period 3', 'Lab'];
    case ModuleId.homework:
    case ModuleId.assignments:
      return const ['Title', 'Class', 'Subject', 'Due', 'Submissions'];
    case ModuleId.exams:
      return const ['Exam', 'Class', 'Subject', 'Date', 'Status'];
    case ModuleId.fees:
      return const ['Student', 'Invoice', 'Amount', 'Due Date', 'Status'];
    case ModuleId.reports:
      return const ['Report', 'Scope', 'Format', 'Generated', 'Owner'];
    case ModuleId.files:
      return const ['File', 'Class', 'Type', 'Size', 'Owner'];
    case ModuleId.leave:
      return const ['Teacher', 'Type', 'Dates', 'Status', 'Approver'];
    default:
      return const ['Name', 'Code', 'Group', 'Status', 'Owner'];
  }
}

List<List<String>> _rowsFor(ModuleId module, UserRole role, String className) {
  switch (module) {
    case ModuleId.teachers:
      return const [
        ['Ananya Rao', 'T-1024', 'Mathematics', 'Active', 'Grade 10-A'],
        ['Rohan Sen', 'T-1031', 'Physics', 'Active', 'Grade 9-B'],
        ['Meera Das', 'T-1042', 'English', 'On Leave', 'Grade 8-C'],
        ['Irfan Ali', 'T-1055', 'Computer Science', 'Active', 'Grade 11-A'],
      ];
    case ModuleId.students:
      return [
        ['Aarav Mehta', 'S-2201', className, 'Active', 'Parent verified'],
        ['Diya Nair', 'S-2202', className, 'Active', 'Scholarship'],
        ['Kabir Singh', 'S-2203', className, 'Attention', 'Attendance watch'],
        ['Sara Khan', 'S-2204', className, 'Active', 'Transport'],
      ];
    case ModuleId.attendance:
      return const [
        ['Aarav Mehta', '01', 'Present', '08:24 AM', 'On time'],
        ['Diya Nair', '02', 'Present', '08:20 AM', 'On time'],
        ['Kabir Singh', '03', 'Absent', '-', 'Parent notified'],
        ['Sara Khan', '04', 'Late', '08:48 AM', 'Bus delay'],
      ];
    case ModuleId.marks:
      return const [
        ['Aarav Mehta', 'Mid Term', 'Math', '92/100', 'A+'],
        ['Diya Nair', 'Mid Term', 'Science', '88/100', 'A'],
        ['Kabir Singh', 'Weekly Test', 'English', '71/100', 'B'],
        ['Sara Khan', 'Project', 'Social', '95/100', 'A+'],
      ];
    case ModuleId.timetable:
      return const [
        ['Monday', 'Math', 'Science', 'English', 'Computer Lab'],
        ['Tuesday', 'Physics', 'Hindi', 'Social', 'Library'],
        ['Wednesday', 'Chemistry', 'Math', 'Sports', 'Robotics'],
        ['Thursday', 'English', 'Biology', 'Art', 'Revision'],
      ];
    case ModuleId.homework:
    case ModuleId.assignments:
      return [
        ['Algebra worksheet', className, 'Mathematics', 'Tomorrow', '34/40'],
        ['Lab observation', className, 'Science', 'Fri', '29/40'],
        ['Essay draft', className, 'English', 'Mon', '37/40'],
        ['Map activity', className, 'Geography', 'Wed', '31/40'],
      ];
    case ModuleId.exams:
      return [
        ['Unit Test 2', className, 'Mathematics', '18 Jul 2026', 'Scheduled'],
        ['Practical Viva', className, 'Science', '22 Jul 2026', 'Draft'],
        ['Term 1', className, 'All Subjects', '04 Aug 2026', 'Published'],
      ];
    case ModuleId.fees:
      return const [
        ['Aarav Mehta', 'INV-1029', '₹42,000', '10 Jul', 'Paid'],
        ['Diya Nair', 'INV-1030', '₹42,000', '10 Jul', 'Pending'],
        ['Kabir Singh', 'INV-1031', '₹42,000', '15 Jul', 'Reminder sent'],
        ['Sara Khan', 'INV-1032', '₹38,500', '15 Jul', 'Paid'],
      ];
    case ModuleId.reports:
      return [
        ['Attendance summary', className, 'PDF', 'Today', 'Admin'],
        ['Marks analysis', className, 'Excel', 'Yesterday', 'Teacher'],
        ['Fee ledger', 'All classes', 'Excel', 'Today', 'Accounts'],
        ['Parent meeting notes', className, 'PDF', '2 days ago', 'Class teacher'],
      ];
    case ModuleId.files:
      return [
        ['Chapter 4 notes.pdf', className, 'PDF', '3.2 MB', 'Ananya Rao'],
        ['Science lab rubric.xlsx', className, 'Excel', '890 KB', 'Rohan Sen'],
        ['Parent circular.pdf', className, 'PDF', '420 KB', 'Admin'],
      ];
    case ModuleId.leave:
      return const [
        ['Ananya Rao', 'Casual', '12 Jul', 'Approved', 'Principal'],
        ['Meera Das', 'Medical', '10-14 Jul', 'Pending', 'Super Admin'],
        ['Rohan Sen', 'Half day', '18 Jul', 'Approved', 'Coordinator'],
      ];
    default:
      return [
        ['Grade 10 - A', 'C-10A', 'Senior School', 'Active', 'Ananya Rao'],
        ['Grade 9 - B', 'C-09B', 'High School', 'Active', 'Rohan Sen'],
        ['Grade 8 - C', 'C-08C', 'Middle School', 'Active', 'Meera Das'],
        ['Grade 11 - A', 'C-11A', 'Senior School', 'Active', 'Irfan Ali'],
      ];
  }
}

List<List<String>> _workspaceRows(String tab) {
  switch (tab) {
    case 'Students':
      return _rowsFor(ModuleId.students, UserRole.teacher, 'Grade 10 - A');
    case 'Attendance':
      return _rowsFor(ModuleId.attendance, UserRole.teacher, 'Grade 10 - A');
    case 'Marks':
      return _rowsFor(ModuleId.marks, UserRole.teacher, 'Grade 10 - A');
    case 'Timetable':
      return _rowsFor(ModuleId.timetable, UserRole.teacher, 'Grade 10 - A');
    case 'Homework':
      return _rowsFor(ModuleId.homework, UserRole.teacher, 'Grade 10 - A');
    case 'Exams':
      return _rowsFor(ModuleId.exams, UserRole.teacher, 'Grade 10 - A');
    case 'Files':
      return _rowsFor(ModuleId.files, UserRole.teacher, 'Grade 10 - A');
    case 'Announcements':
      return const [
        ['Science fair briefing', 'Students', 'Published', 'Today', 'Ananya Rao'],
        ['PTM reminder', 'Parents', 'Scheduled', 'Tomorrow', 'Admin'],
      ];
    default:
      return _rowsFor(ModuleId.reports, UserRole.teacher, 'Grade 10 - A');
  }
}

class _Module {
  const _Module(this.id, this.title, this.icon, this.group, {this.teacher = false});
  final ModuleId id;
  final String title;
  final IconData icon;
  final String group;
  final bool teacher;
}

class _Metric {
  const _Metric(this.label, this.value, this.delta, this.icon, this.color);
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;
}

class _Task {
  const _Task(this.title, this.subtitle, this.time, this.icon);
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
}

class _ClassInfo {
  const _ClassInfo(this.name, this.students, this.teacher, this.attendance);
  final String name;
  final int students;
  final String teacher;
  final int attendance;
}

class _TeacherProfile {
  _TeacherProfile({required this.name, required this.subject, required this.grades, required this.status, required this.students, required this.revenue, required this.rating});
  final String name;
  final String subject;
  final String grades;
  String status;
  final int students;
  final double revenue;
  final double rating;
  String get initials => name.trim().split(RegExp(r'\s+')).map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
}

class _CurriculumLesson {
  _CurriculumLesson({required this.title, required this.duration, this.published = true});
  final String title;
  final String duration;
  bool published;
}

class _CurriculumChapter {
  _CurriculumChapter({required this.title, required this.lessons});
  final String title;
  final List<_CurriculumLesson> lessons;
}

class _CurriculumSubject {
  _CurriculumSubject({required this.grade, required this.subject, required this.teacher, required this.chapters});
  final String grade;
  final String subject;
  final String teacher;
  final List<_CurriculumChapter> chapters;
  int get lessonCount => chapters.fold(0, (sum, c) => sum + c.lessons.length);
}

class _RevenueSlice {
  const _RevenueSlice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

const _groups = ['Command', 'People', 'Academics', 'Operations', 'Governance'];
const _classNames = ['Grade 10 - A', 'Grade 9 - B', 'Grade 8 - C', 'Grade 11 - A'];
const _classScopedModules = {ModuleId.attendance, ModuleId.exams, ModuleId.marks, ModuleId.timetable, ModuleId.homework, ModuleId.assignments, ModuleId.files, ModuleId.announcements, ModuleId.reports};

const _modules = [
  _Module(ModuleId.dashboard, 'Dashboard', Icons.dashboard_rounded, 'Command', teacher: true),
  _Module(ModuleId.classWorkspace, 'Class Workspace', Icons.meeting_room_rounded, 'Command', teacher: true),
  _Module(ModuleId.curriculum, 'Curriculum & Lessons', Icons.video_library_rounded, 'Command', teacher: true),
  _Module(ModuleId.revenue, 'Revenue', Icons.trending_up_rounded, 'Command', teacher: true),
  _Module(ModuleId.teachers, 'Teachers', Icons.co_present_rounded, 'People'),
  _Module(ModuleId.students, 'Students', Icons.groups_rounded, 'People', teacher: true),
  _Module(ModuleId.parents, 'Parents', Icons.family_restroom_rounded, 'People'),
  _Module(ModuleId.classes, 'Classes', Icons.apartment_rounded, 'Academics'),
  _Module(ModuleId.sections, 'Sections', Icons.account_tree_rounded, 'Academics'),
  _Module(ModuleId.subjects, 'Subjects', Icons.menu_book_rounded, 'Academics'),
  _Module(ModuleId.assignments, 'Assignments', Icons.assignment_rounded, 'Academics', teacher: true),
  _Module(ModuleId.attendance, 'Attendance', Icons.fact_check_rounded, 'Academics', teacher: true),
  _Module(ModuleId.exams, 'Exams', Icons.workspace_premium_rounded, 'Academics', teacher: true),
  _Module(ModuleId.marks, 'Marks', Icons.grade_rounded, 'Academics', teacher: true),
  _Module(ModuleId.timetable, 'Timetable', Icons.calendar_month_rounded, 'Academics', teacher: true),
  _Module(ModuleId.homework, 'Homework', Icons.home_work_rounded, 'Academics', teacher: true),
  _Module(ModuleId.fees, 'Fees', Icons.payments_rounded, 'Operations'),
  _Module(ModuleId.announcements, 'Announcements', Icons.campaign_rounded, 'Operations', teacher: true),
  _Module(ModuleId.events, 'Events', Icons.event_available_rounded, 'Operations'),
  _Module(ModuleId.reports, 'Reports', Icons.analytics_rounded, 'Operations', teacher: true),
  _Module(ModuleId.files, 'Files', Icons.folder_rounded, 'Operations', teacher: true),
  _Module(ModuleId.leave, 'Leave Requests', Icons.beach_access_rounded, 'Operations', teacher: true),
  _Module(ModuleId.roles, 'Roles & Permissions', Icons.admin_panel_settings_rounded, 'Governance'),
  _Module(ModuleId.settings, 'Settings', Icons.settings_rounded, 'Governance'),
  _Module(ModuleId.logs, 'Activity Logs', Icons.manage_search_rounded, 'Governance'),
  _Module(ModuleId.backup, 'Backup / Restore', Icons.backup_rounded, 'Governance'),
];

const _adminMetrics = [
  _Metric('Active Students', '2,846', '+8.2%', Icons.groups_rounded, Color(0xFF2563EB)),
  _Metric('Attendance Today', '94.8%', '+2.1%', Icons.fact_check_rounded, Color(0xFF059669)),
  _Metric('Fees Collected', '₹42.8L', '+12.4%', Icons.payments_rounded, Color(0xFFEA580C)),
  _Metric('Open Tasks', '37', '-6.0%', Icons.task_alt_rounded, Color(0xFF7C3AED)),
];

const _teacherMetrics = [
  _Metric('Assigned Classes', '4', '+1', Icons.meeting_room_rounded, Color(0xFF2563EB)),
  _Metric('Students', '156', '+4', Icons.groups_rounded, Color(0xFF059669)),
  _Metric('Homework Due', '18', '-3', Icons.home_work_rounded, Color(0xFFEA580C)),
  _Metric('Avg. Marks', '82%', '+5.3%', Icons.grade_rounded, Color(0xFF7C3AED)),
];

const _classMetrics = [
  _Metric('Students', '40', '+2', Icons.groups_rounded, Color(0xFF2563EB)),
  _Metric('Attendance', '95%', '+1.8%', Icons.fact_check_rounded, Color(0xFF059669)),
  _Metric('Homework', '34/40', '+9%', Icons.assignment_turned_in_rounded, Color(0xFFEA580C)),
  _Metric('Class Avg.', '84%', '+4%', Icons.grade_rounded, Color(0xFF7C3AED)),
];

const _adminQueue = [
  _Task('Approve teacher assignment', 'Grade 11-A Physics replacement requested', 'Now', Icons.swap_horiz_rounded),
  _Task('Review pending fee waivers', '8 parent requests need a decision', '12m', Icons.payments_rounded),
  _Task('Publish term timetable', 'Draft conflicts resolved for senior school', '34m', Icons.calendar_month_rounded),
  _Task('Generate board report', 'PDF and Excel bundle for trustees', '1h', Icons.picture_as_pdf_rounded),
];

const _teacherQueue = [
  _Task('Mark attendance', 'Grade 10-A first period starts in 8 minutes', 'Now', Icons.fact_check_rounded),
  _Task('Grade assignments', '18 algebra worksheets pending review', '24m', Icons.assignment_turned_in_rounded),
  _Task('Upload exam marks', 'Unit Test 2 deadline is today', '2h', Icons.grade_rounded),
  _Task('Respond to leave request', 'Student medical leave note attached', '4h', Icons.beach_access_rounded),
];

const _classWorkspaces = [
  _ClassInfo('Grade 10 - A', 40, 'Ananya Rao', 95),
  _ClassInfo('Grade 9 - B', 38, 'Rohan Sen', 92),
  _ClassInfo('Grade 8 - C', 36, 'Meera Das', 89),
];

const _workspaceHeaders = {
  'Students': ['Student', 'Roll No', 'Class', 'Status', 'Notes'],
  'Attendance': ['Student', 'Roll No', 'Status', 'Check-in', 'Remarks'],
  'Marks': ['Student', 'Exam', 'Subject', 'Marks', 'Grade'],
  'Timetable': ['Day', 'Period 1', 'Period 2', 'Period 3', 'Lab'],
  'Homework': ['Title', 'Class', 'Subject', 'Due', 'Submissions'],
  'Exams': ['Exam', 'Class', 'Subject', 'Date', 'Status'],
  'Files': ['File', 'Class', 'Type', 'Size', 'Owner'],
  'Announcements': ['Announcement', 'Audience', 'Status', 'Date', 'Owner'],
  'Reports': ['Report', 'Scope', 'Format', 'Generated', 'Owner'],
};

const _activityRows = [
  ['Priya Admin', 'Teachers', 'Assigned teacher to Grade 10-A', 'Chrome / Windows', 'Today 09:42'],
  ['Ananya Rao', 'Attendance', 'Marked 40 records', 'Edge / Windows', 'Today 08:48'],
  ['Accounts Bot', 'Fees', 'Sent 18 reminders', 'System', 'Today 07:15'],
  ['Principal', 'Reports', 'Downloaded PDF bundle', 'Safari / iPad', 'Yesterday'],
];

List<_TeacherProfile> _seedTeachers() => [
  _TeacherProfile(name: 'Ananya Rao', subject: 'Mathematics', grades: 'Grade 9 - 10', status: 'Active', students: 156, revenue: 84200, rating: 4.9),
  _TeacherProfile(name: 'Rohan Sen', subject: 'Physics', grades: 'Grade 9, Intermediate', status: 'Active', students: 132, revenue: 71800, rating: 4.8),
  _TeacherProfile(name: 'Meera Das', subject: 'English', grades: 'Grade 6 - 8', status: 'On Leave', students: 98, revenue: 42500, rating: 4.7),
  _TeacherProfile(name: 'Irfan Ali', subject: 'Computer Science', grades: 'Grade 10, Intermediate', status: 'Active', students: 121, revenue: 66900, rating: 4.9),
  _TeacherProfile(name: 'Priya Kulkarni', subject: 'Chemistry', grades: 'Intermediate', status: 'Pending approval', students: 0, revenue: 0, rating: 0),
];

List<_CurriculumSubject> _seedCurriculum() => [
  _CurriculumSubject(grade: 'Grade 10', subject: 'Mathematics', teacher: 'Ananya Rao', chapters: [
    _CurriculumChapter(title: 'Real Numbers', lessons: [
      _CurriculumLesson(title: 'Euclid\'s Division Lemma', duration: '18 min'),
      _CurriculumLesson(title: 'Fundamental Theorem of Arithmetic', duration: '22 min'),
    ]),
    _CurriculumChapter(title: 'Polynomials', lessons: [
      _CurriculumLesson(title: 'Geometrical Meaning of Zeros', duration: '20 min'),
      _CurriculumLesson(title: 'Relationship between Zeros & Coefficients', duration: '25 min'),
      _CurriculumLesson(title: 'Division Algorithm', duration: '19 min', published: false),
    ]),
  ]),
  _CurriculumSubject(grade: 'Grade 9', subject: 'Physics', teacher: 'Rohan Sen', chapters: [
    _CurriculumChapter(title: 'Motion', lessons: [
      _CurriculumLesson(title: 'Distance & Displacement', duration: '16 min'),
      _CurriculumLesson(title: 'Equations of Motion', duration: '28 min'),
    ]),
  ]),
  _CurriculumSubject(grade: 'Grade 8', subject: 'English', teacher: 'Meera Das', chapters: [
    _CurriculumChapter(title: 'The Best Christmas Present', lessons: [
      _CurriculumLesson(title: 'Reading & Comprehension', duration: '14 min'),
    ]),
  ]),
];

const _revenueTrend = [38.0, 42.0, 40.0, 47.0, 52.0, 58.0, 61.0];
const _revenueTrendLabels = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

const _topCourseRevenue = [
  _RevenueSlice('Mathematics · Grade 10', 84200, Color(0xFF2563EB)),
  _RevenueSlice('Physics · Grade 9', 71800, Color(0xFF7C3AED)),
  _RevenueSlice('Computer Science', 66900, Color(0xFF059669)),
  _RevenueSlice('English · Grade 6-8', 42500, Color(0xFFEA580C)),
];

const _backupRows = [
  ['Daily encrypted backup', '1.8 TB', 'Completed 04:12 AM'],
  ['Weekly restore snapshot', '1.7 TB', 'Verified Sunday'],
  ['Pre-upgrade restore point', '1.6 TB', 'Locked 28 Jun'],
];

abstract final class _SaasTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF16385E),
      brightness: brightness,
      primary: const Color(0xFF16385E),
      secondary: const Color(0xFFF5810C),
      tertiary: const Color(0xFFF5810C),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Arial',
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: TextTheme(
        displaySmall: TextStyle(fontSize: 44, height: .98, fontWeight: FontWeight.w900, color: scheme.onSurface),
        headlineMedium: TextStyle(fontSize: 30, height: 1.04, fontWeight: FontWeight.w900, color: scheme.onSurface),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: scheme.onSurface),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: scheme.onSurface),
        bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: scheme.onSurfaceVariant),
        bodySmall: TextStyle(fontSize: 12, height: 1.35, color: scheme.onSurfaceVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), textStyle: const TextStyle(fontWeight: FontWeight.w900))),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      }),
    );
  }
}
