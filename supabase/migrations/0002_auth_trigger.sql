-- ============================================================
-- 0002_auth_trigger.sql
-- Auto-creates a `profiles` row whenever someone signs up via
-- Supabase Auth. Your schema comment says this trigger exists
-- "in Step 3" but it was never actually included — without it,
-- every signup would succeed in auth.users while the app-level
-- profile silently never gets created.
--
-- The app must pass these at signUp() time, e.g.:
--   supabase.auth.signUp(
--     email: ..., password: ...,
--     data: {
--       'name': 'Jane Doe',
--       'role': 'student',           -- student | teacher | admin
--       'grade': 'class8',           -- required for students, else null
--       'age': 13,
--     },
--   )
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, role, grade, age, assigned_subjects)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'role', 'student'),
    new.raw_user_meta_data ->> 'grade',
    nullif(new.raw_user_meta_data ->> 'age', '')::int,
    coalesce(
      (select array_agg(x) from jsonb_array_elements_text(
        coalesce(new.raw_user_meta_data -> 'assigned_subjects', '[]'::jsonb)
      ) as x),
      '{}'
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- keep `updated_at` columns honest
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on profiles;
create trigger trg_profiles_updated_at before update on profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_courses_updated_at on courses;
create trigger trg_courses_updated_at before update on courses
  for each row execute function public.set_updated_at();

drop trigger if exists trg_assessments_updated_at on assessments;
create trigger trg_assessments_updated_at before update on assessments
  for each row execute function public.set_updated_at();

drop trigger if exists trg_assessment_submissions_updated_at on assessment_submissions;
create trigger trg_assessment_submissions_updated_at before update on assessment_submissions
  for each row execute function public.set_updated_at();

drop trigger if exists trg_project_submissions_updated_at on project_submissions;
create trigger trg_project_submissions_updated_at before update on project_submissions
  for each row execute function public.set_updated_at();
