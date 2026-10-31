-- Supabase schema (Part 2) - requires external setup
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "profiles_select_own" on profiles
  for select using (auth.uid() = id);

create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id);

-- auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- books table
create table if not exists books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  grade text not null,
  subject text not null,
  chapter text,
  lesson text,
  year text,
  difficulty text,
  type text,
  source text,
  review_status text,
  is_premium boolean default false,
  correct_answer text,
  solution text,
  is_available boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table books enable row level security;

create policy "books_select_available" on books
  for select using (is_available = true);

create policy "books_insert_denied" on books
  for insert with check (false);

create policy "books_update_denied" on books
  for update with check (false);
