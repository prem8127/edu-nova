-- ============================================================
-- 0004_rls_policies.sql
-- Enables Row Level Security on every table and adds policies.
-- Without this file, your anon/publishable key can read and
-- write EVERYTHING in every table below (this is the #1 fix).
-- ============================================================

-- ---------- PROFILES ----------
alter table profiles enable row level security;

create policy "profiles_select_own_or_admin_or_teacher"
on profiles for select
using (
  id = auth.uid()
  or public.is_admin()
  or public.is_teacher()   -- teachers need to see student names/grades
);

create policy "profiles_update_own_limited"
on profiles for update
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

-- inserts happen via the handle_new_user() trigger (security definer),
-- so no client-facing insert policy is needed. Admins may still insert
-- directly (e.g. seeding teacher accounts).
create policy "profiles_insert_admin_only"
on profiles for insert
with check (public.is_admin());

create policy "profiles_delete_admin_only"
on profiles for delete
using (public.is_admin());

-- ---------- COURSES ----------
alter table courses enable row level security;

create policy "courses_select_all_authenticated"
on courses for select
using (auth.role() = 'authenticated');

create policy "courses_write_teacher_owner_or_admin"
on courses for insert
with check (public.is_admin() or teacher_id = auth.uid());

create policy "courses_update_owner_or_admin"
on courses for update
using (public.owns_course(id))
with check (public.is_admin() or teacher_id = auth.uid());

create policy "courses_delete_owner_or_admin"
on courses for delete
using (public.owns_course(id));

-- ---------- QUIZZES / QUESTIONS / ATTEMPTS ----------
alter table quizzes enable row level security;
alter table quiz_questions enable row level security;
alter table quiz_attempts enable row level security;

create policy "quizzes_select_enrolled_or_owner"
on quizzes for select
using (public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "quizzes_write_owner_or_admin"
on quizzes for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

create policy "quiz_questions_select_enrolled_or_owner"
on quiz_questions for select
using (
  exists (select 1 from quizzes q where q.id = quiz_id and
    (public.is_enrolled(q.course_id) or public.owns_course(q.course_id)))
);

create policy "quiz_questions_write_owner_or_admin"
on quiz_questions for all
using (
  exists (select 1 from quizzes q where q.id = quiz_id and public.owns_course(q.course_id))
)
with check (
  exists (select 1 from quizzes q where q.id = quiz_id and public.owns_course(q.course_id))
);

create policy "quiz_attempts_select_own_or_teacher_or_admin"
on quiz_attempts for select
using (student_id = auth.uid() or public.owns_course(course_id));

create policy "quiz_attempts_insert_own"
on quiz_attempts for insert
with check (student_id = auth.uid() and public.is_enrolled(course_id));

-- ---------- SCHEDULED CLASSES ----------
alter table scheduled_classes enable row level security;

create policy "scheduled_classes_select_enrolled_or_owner"
on scheduled_classes for select
using (public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "scheduled_classes_write_owner_or_admin"
on scheduled_classes for all
using (public.owns_course(course_id))
with check (public.is_admin() or teacher_id = auth.uid());

-- ---------- DOUBT CHAT ----------
alter table doubt_threads enable row level security;
alter table doubt_messages enable row level security;

create policy "doubt_threads_participants_or_admin"
on doubt_threads for select
using (student_id = auth.uid() or teacher_id = auth.uid() or public.is_admin());

create policy "doubt_threads_insert_participant"
on doubt_threads for insert
with check (student_id = auth.uid() or teacher_id = auth.uid() or public.is_admin());

create policy "doubt_messages_participants_or_admin"
on doubt_messages for select
using (
  exists (
    select 1 from doubt_threads t where t.id = thread_id
    and (t.student_id = auth.uid() or t.teacher_id = auth.uid() or public.is_admin())
  )
);

create policy "doubt_messages_insert_participant"
on doubt_messages for insert
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from doubt_threads t where t.id = thread_id
    and (t.student_id = auth.uid() or t.teacher_id = auth.uid())
  )
);

-- ---------- TRANSACTIONS ----------
-- NOTE: purchases should ideally be written by a trusted server-side
-- process (edge function / payment webhook using the service_role key),
-- not directly by the client. The insert policy below is a reasonable
-- default for a "record my own purchase" flow but does not itself
-- verify that money actually changed hands.
alter table transactions enable row level security;

create policy "transactions_select_own_or_teacher_or_admin"
on transactions for select
using (student_id = auth.uid() or teacher_id = auth.uid() or public.is_admin());

create policy "transactions_insert_own"
on transactions for insert
with check (student_id = auth.uid());

-- ---------- SYLLABUS (public reference data) ----------
alter table syllabus_class_plans enable row level security;
alter table syllabus_modules enable row level security;
alter table essential_books enable row level security;

create policy "syllabus_class_plans_read_all"
on syllabus_class_plans for select using (true);
create policy "syllabus_class_plans_write_admin"
on syllabus_class_plans for all using (public.is_admin()) with check (public.is_admin());

create policy "syllabus_modules_read_all"
on syllabus_modules for select using (true);
create policy "syllabus_modules_write_admin"
on syllabus_modules for all using (public.is_admin()) with check (public.is_admin());

create policy "essential_books_read_all"
on essential_books for select using (true);
create policy "essential_books_write_admin"
on essential_books for all using (public.is_admin()) with check (public.is_admin());

-- ---------- ASSESSMENTS ----------
alter table assessments enable row level security;
alter table assessment_submissions enable row level security;

create policy "assessments_select_enrolled_or_owner"
on assessments for select
using (public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "assessments_write_owner_or_admin"
on assessments for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

create policy "assessment_submissions_select_own_or_owner"
on assessment_submissions for select
using (student_id = auth.uid() or public.owns_course(course_id));

create policy "assessment_submissions_insert_own"
on assessment_submissions for insert
with check (student_id = auth.uid() and public.is_enrolled(course_id));

create policy "assessment_submissions_update_own_or_teacher"
on assessment_submissions for update
using (student_id = auth.uid() or public.owns_course(course_id))
with check (student_id = auth.uid() or public.owns_course(course_id));

-- ---------- MINI PROJECTS ----------
alter table mini_projects enable row level security;
alter table project_submissions enable row level security;

create policy "mini_projects_select_enrolled_or_owner"
on mini_projects for select
using (public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "mini_projects_write_owner_or_admin"
on mini_projects for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

create policy "project_submissions_select_own_or_owner"
on project_submissions for select
using (student_id = auth.uid() or public.owns_course(course_id));

create policy "project_submissions_insert_own"
on project_submissions for insert
with check (student_id = auth.uid() and public.is_enrolled(course_id));

create policy "project_submissions_update_own_or_teacher"
on project_submissions for update
using (student_id = auth.uid() or public.owns_course(course_id))
with check (student_id = auth.uid() or public.owns_course(course_id));

-- ---------- CERTIFICATES ----------
alter table certificates enable row level security;

create policy "certificates_select_own_or_owner_or_admin"
on certificates for select
using (student_id = auth.uid() or public.owns_course(course_id));

create policy "certificates_write_owner_or_admin"
on certificates for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

-- ---------- ATTENDANCE ----------
alter table attendance_records enable row level security;

create policy "attendance_select_own_or_owner"
on attendance_records for select
using (student_id = auth.uid() or public.owns_course(course_id));

create policy "attendance_write_owner_or_admin"
on attendance_records for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

-- ---------- NOTIFICATIONS ----------
alter table notifications enable row level security;

create policy "notifications_select_own"
on notifications for select
using (user_id = auth.uid() or public.is_admin());

create policy "notifications_update_own"
on notifications for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "notifications_insert_teacher_or_admin"
on notifications for insert
with check (public.is_teacher() or public.is_admin());

-- ---------- ANNOUNCEMENTS ----------
alter table announcements enable row level security;

create policy "announcements_select_enrolled_or_owner"
on announcements for select
using (public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "announcements_write_owner_or_admin"
on announcements for all
using (public.owns_course(course_id))
with check (public.is_admin() or teacher_id = auth.uid());

-- ---------- RECORDINGS ----------
alter table recordings enable row level security;

create policy "recordings_select_enrolled_owner_or_sample"
on recordings for select
using (is_sample = true or public.is_enrolled(course_id) or public.owns_course(course_id));

create policy "recordings_write_owner_or_admin"
on recordings for all
using (public.owns_course(course_id))
with check (public.owns_course(course_id));

-- ---------- AUDIT LOG (admin only) ----------
alter table audit_log enable row level security;

create policy "audit_log_admin_only_select"
on audit_log for select
using (public.is_admin());

create policy "audit_log_insert_any_authenticated"
on audit_log for insert
with check (auth.role() = 'authenticated');

-- ---------- TEACHER AVAILABILITY ----------
alter table teacher_availability enable row level security;

create policy "teacher_availability_read_all"
on teacher_availability for select using (true);

create policy "teacher_availability_write_own_or_admin"
on teacher_availability for all
using (teacher_id = auth.uid() or public.is_admin())
with check (teacher_id = auth.uid() or public.is_admin());

-- ---------- GAME SCORES ----------
alter table game_scores enable row level security;

create policy "game_scores_select_own_or_admin_or_teacher"
on game_scores for select
using (student_id = auth.uid() or public.is_admin() or public.is_teacher());

create policy "game_scores_write_own"
on game_scores for all
using (student_id = auth.uid())
with check (student_id = auth.uid());
