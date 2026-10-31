-- Supabase Edge Function: activate_subscription
-- Called from Flutter via RPC: `activate_subscription(p_user_id, p_code)`
-- Verifies code, checks limits and activates the purchased tier for its configured duration (silver=30 days, gold=75 days).

create or replace function activate_subscription(p_user_id uuid, p_code text)
returns boolean as $$
declare
  v_code_id uuid;
  v_is_used boolean;
  v_attempts integer;
  v_max_attempts constant integer := 3;
  v_expires_at timestamptz;
  v_starts_at timestamptz;
  v_new_expires timestamptz;
  v_tier text;
  v_duration_days integer;
begin
  -- Find the code by hash
  select id, is_used, expires_at, tier, duration_days into v_code_id, v_is_used, v_expires_at, v_tier, v_duration_days
  from activation_codes
  where code_hash = crypt(p_code, gen_salt('bf'))
  limit 1;

  if v_code_id is null then
    insert into activation_logs (user_id, code_id, success, reason)
    values (p_user_id, null, false, 'invalid_code');
    return false;
  end if;

  if v_is_used then
    insert into activation_logs (user_id, code_id, success, reason)
    values (p_user_id, v_code_id, false, 'already_used');
    return false;
  end if;

  if v_expires_at is not null and v_expires_at < now() then
    insert into activation_logs (user_id, code_id, success, reason)
    values (p_user_id, v_code_id, false, 'expired');
    return false;
  end if;

  -- Check attempts
  select count(*) into v_attempts
  from activation_logs
  where user_id = p_user_id and success = false and created_at > now() - interval '1 hour';

  if v_attempts >= v_max_attempts then
    insert into activation_logs (user_id, code_id, success, reason)
    values (p_user_id, v_code_id, false, 'too_many_attempts');
    return false;
  end if;

  -- Legacy codes default to silver for 30 days. New gold codes must be minted with tier='gold' and duration_days=75.
  v_tier := coalesce(v_tier, 'silver');
  v_duration_days := coalesce(v_duration_days, case when v_tier = 'gold' then 75 else 30 end);
  if v_tier not in ('silver', 'gold') or v_duration_days not in (30, 75) then
    insert into activation_logs (user_id, code_id, success, reason) values (p_user_id, v_code_id, false, 'invalid_plan_configuration');
    return false;
  end if;
  v_starts_at := now();
  v_new_expires := v_starts_at + make_interval(days => v_duration_days);

  update activation_codes
  set is_used = true, used_by = p_user_id, used_at = now()
  where id = v_code_id;

  insert into subscriptions (user_id, status, tier, starts_at, expires_at, activated_by_code_id, source)
  values (p_user_id, 'premium', v_tier, v_starts_at, v_new_expires, v_code_id, 'code');

  insert into activation_logs (user_id, code_id, success, reason)
  values (p_user_id, v_code_id, true, 'success');

  return true;
end;
$$ language plpgsql security definer;