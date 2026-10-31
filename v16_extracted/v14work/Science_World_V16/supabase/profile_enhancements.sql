-- Profile enhancements for Science World.
-- Apply in Supabase SQL Editor after reviewing the existing schema.
alter table public.profiles
  add column if not exists grade text,
  add column if not exists branch text,
  add column if not exists student_number text unique,
  add column if not exists avatar_url text;

-- Keep profile reads and updates restricted to the authenticated owner.
alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated using (auth.uid() = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated using (auth.uid() = id)
  with check (auth.uid() = id);

-- Allow authenticated users to create only their own profile row.
drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (auth.uid() = id);

-- Generate a stable student number for new profiles; existing records remain untouched.
create or replace function public.assign_student_number()
returns trigger language plpgsql as $$
begin
  if new.student_number is null or btrim(new.student_number) = '' then
    new.student_number := 'SW-' || upper(substr(replace(new.id::text, '-', ''), 1, 10));
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_assign_student_number on public.profiles;
create trigger profiles_assign_student_number
before insert on public.profiles
for each row execute function public.assign_student_number();

-- Backfill identifiers for existing users without exposing or changing user IDs.
update public.profiles
set student_number = 'SW-' || upper(substr(replace(id::text, '-', ''), 1, 10))
where student_number is null or btrim(student_number) = '';
