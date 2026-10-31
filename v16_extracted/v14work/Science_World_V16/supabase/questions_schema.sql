-- Supabase SQL for Science World question bank

-- Table for questions
create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  grade text not null,
  subject text not null,
  chapter text,
  lesson text,
  school_year text,
  difficulty text,
  type text not null,
  source text not null,
  review_status text not null,
  is_paid boolean not null default false,
  correct_answer text not null,
  solution text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Table for question versions
create table if not exists question_versions (
  question_id uuid references questions(id) on delete cascade,
  version int not null,
  content jsonb not null,
  created_at timestamptz not null default now(),
  primary key (question_id, version)
);

-- Table for tags (type, difficulty, etc.)
create table if not exists question_tags (
  question_id uuid references questions(id) on delete cascade,
  tag text not null,
  primary key (question_id, tag)
);

-- Enable RLS for questions
alter table questions enable row level security;

-- Permissions for public (free) questions
create policy "public_read" on questions for select using (is_paid = false);

-- Permission for paid content (access controlled by application logic)
create policy "paid_read" on questions for select using (is_paid = true and auth.role() = 'authenticated');

-- Deny insert/update/delete from clients
create policy "deny_all_insert" on questions for insert using (false);
create policy "deny_all_update" on questions for update using (false);
create policy "deny_all_delete" on questions for delete using (false);

-- Similar policies for versions and tags can be added as needed
