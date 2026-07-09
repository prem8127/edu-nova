-- ============================================================
-- 0003_rls_helpers.sql
-- Small helper functions the RLS policies below rely on.
-- All are `security definer` + `stable` so they can be called
-- inside policy expressions cheaply and without recursive RLS
-- checks on `profiles` itself.
-- ============================================================

create or replace function public.my_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from profiles where id = auth.uid();
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select role from profiles where id = auth.uid()) = 'admin', false);
$$;

create or replace function public.is_teacher()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select role from profiles where id = auth.uid()) = 'teacher', false);
$$;

-- Is the current user the teacher who owns this course (or an admin)?
create or replace function public.owns_course(target_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin() or exists (
    select 1 from courses c
    where c.id = target_course_id and c.teacher_id = auth.uid()
  );
$$;

-- Has the current student purchased this course (course price = 0 counts
-- as free/enrolled-by-default)?
create or replace function public.is_enrolled(target_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or public.owns_course(target_course_id)
    or exists (
      select 1 from courses c where c.id = target_course_id and c.price = 0
    )
    or exists (
      select 1 from transactions t
      where t.course_id = target_course_id
        and t.student_id = auth.uid()
        and t.status = 'success'
    );
$$;
