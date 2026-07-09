-- ============================================================
-- 0001_schema.sql
-- Base schema (as supplied), unchanged except:
--   * added `updated_at` to a few tables that clearly get edited
--     after creation (profiles, courses, assessments, submissions)
--   * a few extra FK indexes Postgres doesn't create automatically
-- ============================================================

create extension if not exists pgcrypto;

-- ========== PROFILES (extends auth.users) ==========
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null check (role in ('student','teacher','admin')),
  grade text check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  age int,
  assigned_subjects text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ========== COURSES ==========
create table if not exists courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  subject text not null check (subject in ('tech','business','finance','contentCreation')),
  grade text not null check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  teacher_id uuid references profiles(id) on delete set null,
  price numeric not null default 0,
  game_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ========== QUIZZES ==========
create table if not exists quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  created_at timestamptz not null default now()
);

create table if not exists quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references quizzes(id) on delete cascade,
  question text not null,
  options text[] not null,
  correct_option_index int not null,
  order_index int not null default 0
);

create table if not exists quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles(id) on delete cascade,
  quiz_id uuid not null references quizzes(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  score int not null,
  total_questions int not null,
  taken_at timestamptz not null default now()
);

-- ========== SCHEDULED CLASSES ==========
create table if not exists scheduled_classes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  teacher_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  date_time timestamptz not null,
  duration_minutes int not null default 60,
  zoom_link text,
  created_at timestamptz not null default now()
);

-- ========== DOUBT CHAT ==========
create table if not exists doubt_threads (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles(id) on delete cascade,
  teacher_id uuid not null references profiles(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (student_id, teacher_id, course_id)
);

create table if not exists doubt_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references doubt_threads(id) on delete cascade,
  sender_id uuid not null references profiles(id) on delete cascade,
  text text not null,
  sent_at timestamptz not null default now()
);

-- ========== TRANSACTIONS ==========
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  teacher_id uuid not null references profiles(id) on delete cascade,
  amount numeric not null,
  status text not null default 'success' check (status in ('success','refunded')),
  created_at timestamptz not null default now()
);

-- ========== SYLLABUS ==========
create table if not exists syllabus_class_plans (
  id uuid primary key default gen_random_uuid(),
  grade text not null check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  class_name text not null,
  stage_label text not null,
  projects text[] not null default '{}'
);

create table if not exists syllabus_modules (
  id uuid primary key default gen_random_uuid(),
  class_plan_id uuid not null references syllabus_class_plans(id) on delete cascade,
  title text not null,
  topics text[] not null default '{}',
  order_index int not null default 0
);

create table if not exists essential_books (
  level text primary key,
  books text[] not null default '{}'
);

-- ========== ASSESSMENTS ==========
create table if not exists assessments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  subject text not null check (subject in ('tech','business','finance','contentCreation')),
  grade text not null check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  type text not null check (type in ('coding','mcq','calculation','writing')),
  title text not null,
  prompt text not null,
  points int not null default 100,
  due_date timestamptz,
  starter_code text not null default '',
  test_cases jsonb not null default '[]',
  expected_answer numeric,
  tolerance numeric not null default 0.01,
  unit text not null default '',
  options text[] not null default '{}',
  correct_option_index int not null default 0,
  min_words int not null default 120,
  rubric text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists assessment_submissions (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references assessments(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  student_id uuid not null references profiles(id) on delete cascade,
  type text not null check (type in ('coding','mcq','calculation','writing')),
  content text not null default '',
  numeric_answer numeric,
  selected_option int,
  status text not null default 'submitted' check (status in ('draft','submitted','aiFlagged','underReview','approved','needsWork')),
  auto_score int,
  teacher_score int,
  ai_feedback text not null default '',
  teacher_feedback text not null default '',
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (assessment_id, student_id)
);

-- ========== MINI PROJECTS ==========
create table if not exists mini_projects (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  subject text not null check (subject in ('tech','business','finance','contentCreation')),
  grade text not null check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  title text not null,
  brief text not null,
  deliverables text[] not null default '{}'
);

create table if not exists project_submissions (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references mini_projects(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  student_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  description text not null,
  link text not null default '',
  status text not null default 'submitted' check (status in ('draft','submitted','aiFlagged','underReview','approved','needsWork')),
  ai_precheck text not null default '',
  teacher_feedback text not null default '',
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ========== CERTIFICATES ==========
create table if not exists certificates (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references profiles(id) on delete cascade,
  student_name text not null,
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  subject text not null check (subject in ('tech','business','finance','contentCreation')),
  grade text not null check (grade in ('class6','class7','class8','class9','class10','intermediate1','intermediate2')),
  score_percent int not null,
  issued_at timestamptz not null default now()
);

-- ========== ATTENDANCE ==========
create table if not exists attendance_records (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references scheduled_classes(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  student_id uuid not null references profiles(id) on delete cascade,
  status text not null check (status in ('present','absent','late')),
  marked_at timestamptz not null default now(),
  unique (class_id, student_id)
);

-- ========== NOTIFICATIONS ==========
create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  type text not null check (type in ('classReminder','examDeadline','doubtReply','announcement','certificate','submissionResult')),
  title text not null,
  body text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

-- ========== ANNOUNCEMENTS ==========
create table if not exists announcements (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  teacher_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  body text not null,
  created_at timestamptz not null default now()
);

-- ========== RECORDINGS ==========
create table if not exists recordings (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references scheduled_classes(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  is_sample boolean not null default false,
  share_url text not null default '',
  created_at timestamptz not null default now()
);

-- ========== AUDIT LOG ==========
create table if not exists audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references profiles(id) on delete set null,
  actor_name text not null,
  action text not null,
  target text not null,
  created_at timestamptz not null default now()
);

-- ========== TEACHER AVAILABILITY ==========
create table if not exists teacher_availability (
  teacher_id uuid primary key references profiles(id) on delete cascade,
  slots text[] not null default '{}'
);

-- ========== GAME SCORES ==========
create table if not exists game_scores (
  student_id uuid not null references profiles(id) on delete cascade,
  game_key text not null,
  best_score int not null,
  primary key (student_id, game_key)
);

-- ========== INDEXES ==========
create index if not exists idx_courses_grade_subject on courses (grade, subject);
create index if not exists idx_courses_teacher on courses (teacher_id);
create index if not exists idx_quiz_questions_quiz on quiz_questions (quiz_id);
create index if not exists idx_quizzes_course on quizzes (course_id);
create index if not exists idx_quiz_attempts_student on quiz_attempts (student_id);
create index if not exists idx_quiz_attempts_course on quiz_attempts (course_id);
create index if not exists idx_scheduled_classes_course on scheduled_classes (course_id);
create index if not exists idx_scheduled_classes_teacher on scheduled_classes (teacher_id);
create index if not exists idx_doubt_threads_student on doubt_threads (student_id);
create index if not exists idx_doubt_threads_teacher on doubt_threads (teacher_id);
create index if not exists idx_doubt_messages_thread on doubt_messages (thread_id);
create index if not exists idx_doubt_messages_sender on doubt_messages (sender_id);
create index if not exists idx_transactions_student on transactions (student_id);
create index if not exists idx_transactions_teacher on transactions (teacher_id);
create index if not exists idx_transactions_course on transactions (course_id);
create index if not exists idx_notifications_user on notifications (user_id);
create index if not exists idx_assessments_course on assessments (course_id);
create index if not exists idx_assessment_submissions_student on assessment_submissions (student_id);
create index if not exists idx_assessment_submissions_assessment on assessment_submissions (assessment_id);
create index if not exists idx_mini_projects_course on mini_projects (course_id);
create index if not exists idx_project_submissions_student on project_submissions (student_id);
create index if not exists idx_project_submissions_project on project_submissions (project_id);
create index if not exists idx_attendance_student on attendance_records (student_id);
create index if not exists idx_attendance_class on attendance_records (class_id);
create index if not exists idx_certificates_student on certificates (student_id);
create index if not exists idx_announcements_course on announcements (course_id);
create index if not exists idx_recordings_course on recordings (course_id);
create index if not exists idx_recordings_class on recordings (class_id);
create index if not exists idx_audit_log_actor on audit_log (actor_id);
