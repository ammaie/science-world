-- Supabase Edge Function: get_questions
-- Returns questions filtered by subscription status.
-- If user is not premium, only free questions are returned.

create or replace function get_questions(
  p_grade text default null,
  p_subject text default null,
  p_type text default null,
  p_difficulty text default null
)
returns setof questions as $$
declare
  v_user_id uuid := auth.uid();
  v_is_premium boolean := false;
begin
  -- Check if user is premium
  select exists (
    select 1 from subscriptions
    where user_id = v_user_id
      and status = 'premium'
      and (expires_at is null or expires_at > now())
  ) into v_is_premium;

  return query
  select * from questions
  where
    (p_grade is null or grade = p_grade)
    and (p_subject is null or subject = p_subject)
    and (p_type is null or type = p_type)
    and (p_difficulty is null or difficulty = p_difficulty)
    and (v_is_premium or is_paid = false);
end;
$$ language plpgsql security definer;