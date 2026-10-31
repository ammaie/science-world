-- Subscription system schema for Science World
-- Tables: subscriptions, activation_codes, activation_logs, payment_requests

-- 1. Subscriptions table
create table if not exists subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  status text not null default 'free', -- 'free', 'premium', 'expired'
  starts_at timestamptz,
  expires_at timestamptz,
  activated_by_code_id uuid references activation_codes(id) on delete set null,
  source text default 'manual', -- 'manual', 'payment', 'code'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. Activation codes
create table if not exists activation_codes (
  id uuid primary key default gen_random_uuid(),
  code_hash text not null unique,
  is_used boolean default false,
  used_by uuid references auth.users(id) on delete set null,
  used_at timestamptz,
  expires_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  batch_id uuid,
  created_at timestamptz default now()
);

-- 3. Activation logs
create table if not exists activation_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  code_id uuid references activation_codes(id) on delete set null,
  success boolean not null,
  reason text,
  ip text,
  user_agent text,
  created_at timestamptz default now()
);

-- 4. Payment requests (manual via Sham Cash)
create table if not exists payment_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text,
  phone text,
  receipt_url text,
  status text default 'pending', -- 'pending', 'approved', 'rejected'
  admin_note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS Policies
alter table subscriptions enable row level security;
create policy "users_read_own_subscription" on subscriptions for select using (auth.uid() = user_id);
create policy "no_client_write" on subscriptions for insert with check (false);
create policy "no_client_update" on subscriptions for update with check (false);
create policy "no_client_delete" on subscriptions for delete using (false);

alter table activation_codes enable row level security;
create policy "no_client_access_codes" on activation_codes for select using (false);
create policy "no_client_write_codes" on activation_codes for insert with check (false);
create policy "no_client_update_codes" on activation_codes for update using (false);
create policy "no_client_delete_codes" on activation_codes for delete using (false);

alter table activation_logs enable row level security;
create policy "users_read_own_logs" on activation_logs for select using (auth.uid() = user_id);
create policy "no_client_write_logs" on activation_logs for insert with check (false);

alter table payment_requests enable row level security;
create policy "users_read_own_requests" on payment_requests for select using (auth.uid() = user_id);
create policy "users_insert_own_requests" on payment_requests for insert with check (auth.uid() = user_id);
create policy "no_client_update_requests" on payment_requests for update using (false);
create policy "no_client_delete_requests" on payment_requests for delete using (false);