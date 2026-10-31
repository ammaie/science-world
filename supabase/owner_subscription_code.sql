-- Run this migration in Supabase SQL Editor AFTER subscriptions_schema.sql.
-- Owner-only, single-use activation code. Never put the Supabase service-role key in Flutter.
create extension if not exists pgcrypto;

alter table public.activation_codes
  add column if not exists owner_email text;

-- Correct and harden the activation RPC: authenticated user can only activate their own account.
create or replace function public.activate_subscription(p_user_id uuid, p_code text)
returns boolean
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
  v_uid uuid := auth.uid();
  v_email text;
  v_code_id uuid;
  v_hash text;
  v_used boolean;
  v_code_expiry timestamptz;
  v_attempts integer;
  v_start timestamptz := now();
begin
  if v_uid is null or p_user_id is distinct from v_uid then
    return false;
  end if;

  select lower(email) into v_email from auth.users where id = v_uid;
  select id, code_hash, is_used, expires_at
    into v_code_id, v_hash, v_used, v_code_expiry
    from public.activation_codes
   where owner_email = lower(v_email)
     and code_hash = crypt(trim(p_code), code_hash)
   for update;

  if v_code_id is null or v_used or (v_code_expiry is not null and v_code_expiry <= now()) then
    insert into public.activation_logs(user_id, code_id, success, reason)
    values (v_uid, v_code_id, false, 'invalid_or_unavailable_code');
    return false;
  end if;

  select count(*) into v_attempts from public.activation_logs
   where user_id = v_uid and success = false and created_at > now() - interval '1 hour';
  if v_attempts >= 5 then
    insert into public.activation_logs(user_id, code_id, success, reason)
    values (v_uid, v_code_id, false, 'too_many_attempts');
    return false;
  end if;

  update public.activation_codes
     set is_used = true, used_by = v_uid, used_at = now()
   where id = v_code_id and is_used = false;
  if not found then return false; end if;

  insert into public.subscriptions(user_id, status, starts_at, expires_at, activated_by_code_id, source)
  values (v_uid, 'premium', v_start, v_start + interval '1 year', v_code_id, 'owner_code')
  on conflict do nothing;

  -- If this account already has a subscription row, renew/upgrade that row.
  update public.subscriptions
     set status='premium', starts_at=v_start, expires_at=v_start + interval '1 year',
         activated_by_code_id=v_code_id, source='owner_code', updated_at=now()
   where user_id=v_uid
     and not exists (select 1 from public.subscriptions s2 where s2.user_id=v_uid and s2.activated_by_code_id=v_code_id);

  insert into public.activation_logs(user_id, code_id, success, reason)
  values (v_uid, v_code_id, true, 'owner_code_activated');
  return true;
end;
$$;

revoke all on function public.activate_subscription(uuid, text) from public;
grant execute on function public.activate_subscription(uuid, text) to authenticated;

-- Private owner code. It is bound to this email and can only be redeemed once.
insert into public.activation_codes(code_hash, owner_email, is_used, expires_at)
values (crypt('SW-RYC2-AGRA-N7ZU-AGGR', gen_salt('bf')), lower('nurl70666@gmail.com'), false, now() + interval '30 days');
