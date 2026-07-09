-- Run this once in Supabase Dashboard -> SQL Editor -> New query.
-- Safe to re-run: uses "if not exists" / "or replace" throughout.

-- ── profiles table ─────────────────────────────────────────────────────
-- One row per auth.users row. `grade` is filled once at student sign-up
-- and never re-asked — the app just reads it from here on every login.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  role text not null check (role in ('student','teacher','admin')),
  email text,
  grade text,
  age int,
  gender text,
  assigned_subjects text[] not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Teachers/admins can see every profile (dashboards, student lists, etc).
drop policy if exists "Staff can view all profiles" on public.profiles;
create policy "Staff can view all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles staff
      where staff.id = auth.uid() and staff.role in ('teacher','admin')
    )
  );

-- Admins can create/edit/delete any profile (e.g. fixing a teacher's role
-- after adding them in Authentication -> Users).
drop policy if exists "Admins manage all profiles" on public.profiles;
create policy "Admins manage all profiles"
  on public.profiles for all
  using (
    exists (
      select 1 from public.profiles admin
      where admin.id = auth.uid() and admin.role = 'admin'
    )
  );

-- ── auto-create profile row on signup ─────────────────────────────────
-- supabase.auth.signUp(..., data: {...}) stores that "data" as
-- raw_user_meta_data on the new auth.users row. This trigger copies it
-- into `profiles` the instant the account is created, so the row (and
-- the student's grade) exists even before they've verified their OTP.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, name, role, email, grade, age, gender)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'student'),
    new.email,
    new.raw_user_meta_data ->> 'grade',
    nullif(new.raw_user_meta_data ->> 'age', '')::int,
    new.raw_user_meta_data ->> 'gender'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── keep profiles.email in sync if it ever changes ────────────────────
create or replace function public.handle_user_email_update()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_email_updated on auth.users;
create trigger on_auth_user_email_updated
  after update of email on auth.users
  for each row execute procedure public.handle_user_email_update();
