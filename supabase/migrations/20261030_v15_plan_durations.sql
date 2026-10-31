-- V15: plan durations. Review and apply manually in Supabase SQL Editor.
alter table public.activation_codes
  add column if not exists tier text not null default 'silver' check (tier in ('silver', 'gold')),
  add column if not exists duration_days integer not null default 30 check (duration_days in (30, 75));

alter table public.subscriptions
  add column if not exists tier text not null default 'silver' check (tier in ('silver', 'gold'));

-- Existing codes remain silver for 30 days. To create gold codes, set tier='gold', duration_days=75.
-- Replace activate_subscription with the updated function in supabase/functions/activate_subscription.sql.
