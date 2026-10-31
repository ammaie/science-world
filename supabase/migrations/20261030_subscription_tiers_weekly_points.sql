-- Science World V14: tier metadata and secure weekly challenge storage.
-- Review and apply manually in Supabase SQL Editor; this file is NOT deployed automatically.

alter table if exists public.subscriptions
  add column if not exists tier text not null default 'silver'
  check (tier in ('silver', 'gold'));

create table if not exists public.weekly_challenge_scores (
  user_id uuid not null references auth.users(id) on delete cascade,
  week_start date not null,
  points integer not null default 0 check (points >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, week_start)
);

alter table public.weekly_challenge_scores enable row level security;

-- Students may read only their own score. Do not allow client-side score writes:
-- scores must eventually be recorded by a trusted RPC/Edge Function that validates answers.
drop policy if exists weekly_scores_select_own on public.weekly_challenge_scores;
create policy weekly_scores_select_own on public.weekly_challenge_scores
  for select to authenticated using (auth.uid() = user_id);
drop policy if exists weekly_scores_no_client_insert on public.weekly_challenge_scores;
create policy weekly_scores_no_client_insert on public.weekly_challenge_scores
  for insert to authenticated with check (false);
drop policy if exists weekly_scores_no_client_update on public.weekly_challenge_scores;
create policy weekly_scores_no_client_update on public.weekly_challenge_scores
  for update to authenticated using (false) with check (false);
drop policy if exists weekly_scores_no_client_delete on public.weekly_challenge_scores;
create policy weekly_scores_no_client_delete on public.weekly_challenge_scores
  for delete to authenticated using (false);

create index if not exists weekly_challenge_scores_week_points_idx
  on public.weekly_challenge_scores (week_start desc, points desc);

comment on table public.weekly_challenge_scores is
  'Weekly challenge score history. Client writes are intentionally blocked until trusted server-side scoring is configured.';
