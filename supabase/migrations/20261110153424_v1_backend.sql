-- v1 backend: lock down access, clean up the schema, and move all writes and
-- scoring behind authenticated RPCs.
--
-- Principles
--   * Content tables (topics, quizzes, questions, answers) are read-only to clients.
--   * User-owned tables are read-only to their owner; every write goes through
--     a SECURITY DEFINER function that derives the user from auth.uid().
--     No function accepts a user id from the client.
--   * Scores are computed on the server from answer ids. Clients never send
--     correctness.
--   * Every function pins search_path = '' and fully qualifies names.

-- ===========================================================================
-- 1. Drop the old API surface (functions, triggers, cron)
-- ===========================================================================

do $$
begin
    perform cron.unschedule('hourly-streak-reset');
exception when others then null;
end $$;

drop trigger if exists trg_check_quiz_session on public.user_quiz_sessions;
drop trigger if exists on_public_user_created on public.users;
drop trigger if exists trigger_delete_user_cascade on public.users;
drop trigger if exists on_auth_user_deleted on auth.users;
drop trigger if exists on_auth_user_created on auth.users;

drop function if exists public.check_and_update_streak(uuid);
drop function if exists public.check_quiz_session_before_insert();
drop function if exists public.create_user_on_signup();
drop function if exists public.delete_user_cascade();
drop function if exists public.handle_new_public_user();
drop function if exists public.handle_user_deletion();
drop function if exists public.get_available_quizzes_for_user_for_topic(text, text, integer, integer);
drop function if exists public.get_user_completed_quizzes_by_topic(text, text, integer, integer);
drop function if exists public.get_user_quiz_stats(uuid);
drop function if exists public.mark_abandoned_sessions();
drop function if exists public.reset_expired_streaks();
drop function if exists public.save_quiz_progress(bigint, text, boolean);

-- ===========================================================================
-- 2. Schema clean-up
-- ===========================================================================

-- Fix naming.
alter table public.quizzez rename to quizzes;
alter table public.quizzes rename constraint quizzez_pkey to quizzes_pkey;
alter table public.quizzes rename constraint quizzez_topic_id_fkey to quizzes_topic_id_fkey;
alter table public.questions rename column explaination to explanation;
comment on table public.quizzes is 'All the quizzes in BibleTrivia';

-- Duplicate unique constraints (the primary key already covers them).
alter table public.quizzes drop constraint if exists quizzez_id_key;
alter table public.users drop constraint if exists users_id_key;

-- Columns that held per-user or derived data on shared rows.
alter table public.quizzes drop column if exists status;      -- quiz status is per user (sessions)
alter table public.topics drop column if exists total_points; -- derived from quizzes
alter table public.users drop column if exists streak;        -- lives in user_streaks

-- Tighten content columns.
alter table public.questions alter column text drop default;
alter table public.questions alter column explanation drop default;
alter table public.questions alter column quiz_id drop default;
alter table public.questions alter column quiz_id set not null;
alter table public.answers alter column question_id set not null;
alter table public.answers alter column is_correct set not null;
alter table public.quizzes alter column topic_id drop default;
alter table public.quizzes alter column difficulty set not null;
alter table public.quizzes alter column total_points set not null;
alter table public.quizzes alter column time_to_complete set not null;
comment on column public.quizzes.time_to_complete is 'Estimated minutes to complete';
comment on column public.quizzes.difficulty is '0 New Born … 4 Senior Pastor';

-- Questions get an explicit order.
alter table public.questions add column if not exists position integer not null default 0;

-- Users: the id comes from auth, never from a default.
alter table public.users alter column id drop default;
alter table public.users alter column name set default '';

-- Streaks.
alter table public.user_streaks alter column current_streak set not null;
alter table public.user_streaks alter column longest_streak set not null;

-- Sessions.
alter table public.user_quiz_sessions alter column user_id drop default;
alter table public.user_quiz_sessions alter column answers set not null;
alter table public.user_quiz_sessions alter column attempt_number set not null;
alter table public.user_quiz_sessions
    add column if not exists points_earned bigint not null default 0;
alter table public.user_quiz_sessions
    add constraint user_quiz_sessions_status_check
    check (status in ('in_progress', 'completed', 'abandoned'));

-- Indexes: cover foreign keys, drop redundant ones.
create index if not exists idx_quizzes_topic_id on public.quizzes (topic_id);
create index if not exists idx_questions_quiz_id on public.questions (quiz_id, position);
create index if not exists idx_answers_question_id on public.answers (question_id);
drop index if exists public.idx_user_quiz_sessions_answers;
drop index if exists public.idx_user_quiz_sessions_status;
drop index if exists public.idx_user_quiz_sessions_user_id;
drop index if exists public.idx_user_streaks_user_id;
drop index if exists public.idx_user_streaks_last_visit;

-- ===========================================================================
-- 3. Row level security: replace every policy
-- ===========================================================================

do $$
declare p record;
begin
    for p in
        select policyname, tablename from pg_policies
        where schemaname = 'public'
          and tablename in ('topics','quizzes','questions','answers','users','user_streaks','user_quiz_sessions')
    loop
        execute format('drop policy %I on public.%I', p.policyname, p.tablename);
    end loop;
end $$;

-- Content: readable by signed-in users only.
create policy "Signed-in users can read topics" on public.topics
    for select to authenticated using (true);
create policy "Signed-in users can read quizzes" on public.quizzes
    for select to authenticated using (true);
create policy "Signed-in users can read questions" on public.questions
    for select to authenticated using (true);
create policy "Signed-in users can read answers" on public.answers
    for select to authenticated using (true);

-- User data: owners can read their own rows. All writes go through RPCs.
create policy "Users can read their own profile" on public.users
    for select to authenticated using ((select auth.uid()) = id);
create policy "Users can read their own streak" on public.user_streaks
    for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users can read their own sessions" on public.user_quiz_sessions
    for select to authenticated using ((select auth.uid()) = user_id);

-- Table privileges: no direct writes from clients. Profile name/age are editable.
revoke all on public.topics, public.quizzes, public.questions, public.answers,
              public.users, public.user_streaks, public.user_quiz_sessions
    from anon, authenticated;
grant select on public.topics, public.quizzes, public.questions, public.answers,
               public.users, public.user_streaks, public.user_quiz_sessions
    to authenticated;
grant update (name, age) on public.users to authenticated;
create policy "Users can update their own profile" on public.users
    for update to authenticated
    using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- ===========================================================================
-- 4. Internal helpers (not callable by clients)
-- ===========================================================================

-- Points needed to reach each level. Level is derived from points only.
create or replace function public.level_min_points(p_level integer)
returns bigint language sql immutable set search_path = '' as $$
    select case p_level
        when 0 then 0
        when 1 then 100
        when 2 then 300
        when 3 then 750
        when 4 then 1500
        else null
    end::bigint;
$$;

create or replace function public.level_for_points(p_points bigint)
returns integer language sql immutable set search_path = '' as $$
    select case
        when p_points >= 1500 then 4
        when p_points >= 750 then 3
        when p_points >= 300 then 2
        when p_points >= 100 then 1
        else 0
    end;
$$;

-- Full quiz JSON (quiz + ordered questions + answers). Shape matches QuizDTO on iOS.
create or replace function public.quiz_json(p_quiz_id bigint)
returns jsonb language sql stable set search_path = '' as $$
    select jsonb_build_object(
        'id', q.id,
        'name', q.name,
        'topic_id', q.topic_id,
        'difficulty', q.difficulty,
        'total_points', q.total_points,
        'time_to_complete', q.time_to_complete,
        'questions', coalesce((
            select jsonb_agg(jsonb_build_object(
                'id', qu.id,
                'text', qu.text,
                'explanation', qu.explanation,
                'answers', coalesce((
                    select jsonb_agg(jsonb_build_object(
                        'id', a.id,
                        'text', a.text,
                        'is_correct', a.is_correct
                    ) order by a.id)
                    from public.answers a where a.question_id = qu.id
                ), '[]'::jsonb)
            ) order by qu.position, qu.id)
            from public.questions qu where qu.quiz_id = q.id
        ), '[]'::jsonb)
    )
    from public.quizzes q where q.id = p_quiz_id;
$$;

-- Session JSON. Shape matches QuizSessionDTO on iOS.
create or replace function public.session_json(s public.user_quiz_sessions)
returns jsonb language sql stable set search_path = '' as $$
    select jsonb_build_object(
        'id', s.id,
        'quiz_id', s.quiz_id,
        'status', s.status,
        'started_at', s.started_at,
        'completed_at', s.completed_at,
        'attempt_number', s.attempt_number,
        'answers', s.answers,
        'total_questions', s.total_questions,
        'correct_answers', s.correct_answers,
        'percentage', s.percentage,
        'passed', s.passed,
        'points_earned', s.points_earned,
        'time_spent_seconds', s.time_spent_seconds
    );
$$;

-- Validates client answers [{question_id, answer_id}] against the quiz and
-- returns the graded array [{question_id, answer_id, is_correct, answered_at}].
-- Unknown or mismatched pairs are dropped; one answer per question.
create or replace function public.grade_answers(p_quiz_id bigint, p_answers jsonb)
returns jsonb language sql stable set search_path = '' as $$
    select coalesce(jsonb_agg(jsonb_build_object(
        'question_id', g.question_id,
        'answer_id', g.answer_id,
        'is_correct', g.is_correct,
        'answered_at', now()
    ) order by g.question_id), '[]'::jsonb)
    from (
        select distinct on (qu.id)
            qu.id as question_id, a.id as answer_id, a.is_correct
        from jsonb_array_elements(coalesce(p_answers, '[]'::jsonb)) e
        join public.questions qu
            on qu.id = (e->>'question_id')::bigint and qu.quiz_id = p_quiz_id
        join public.answers a
            on a.id = (e->>'answer_id')::bigint and a.question_id = qu.id
        order by qu.id
    ) g;
$$;

-- Loads the caller's in-progress session or raises.
create or replace function public.require_own_active_session(p_session_id bigint)
returns public.user_quiz_sessions language plpgsql stable set search_path = '' as $$
declare s public.user_quiz_sessions;
begin
    select * into s from public.user_quiz_sessions
    where id = p_session_id and user_id = auth.uid();
    if not found then
        raise exception 'Quiz session not found' using errcode = 'P0002';
    end if;
    if s.status <> 'in_progress' then
        raise exception 'Quiz session is already %', s.status using errcode = 'P0001';
    end if;
    return s;
end;
$$;

-- ===========================================================================
-- 5. Auth triggers
-- ===========================================================================

create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
    insert into public.users (id, name, email, age, joined_at)
    values (
        new.id,
        left(trim(coalesce(new.raw_user_meta_data->>'user_name', '')), 100),
        new.email,
        greatest(0, least(150, coalesce((new.raw_user_meta_data->>'age')::int, 0))),
        coalesce(new.created_at, now())
    );
    insert into public.user_streaks (user_id, current_streak, longest_streak, last_visit)
    values (new.id, 0, 0, now() - interval '2 days');
    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_auth_user();

-- Keep public.users.email in sync after a confirmed email change.
create or replace function public.handle_auth_user_email_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
    update public.users set email = new.email where id = new.id;
    return new;
end;
$$;

create trigger on_auth_user_email_changed
    after update of email on auth.users
    for each row when (old.email is distinct from new.email)
    execute function public.handle_auth_user_email_change();

-- ===========================================================================
-- 6. Client RPCs
-- ===========================================================================

-- Daily check-in. Counts calendar days in the user's time zone.
create or replace function public.check_in(p_time_zone text default 'UTC')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
    uid uuid := auth.uid();
    tz text := p_time_zone;
    s public.user_streaks;
    today date;
    last_day date;
begin
    if uid is null then
        raise exception 'Not authenticated' using errcode = '42501';
    end if;
    if tz is null or not exists (select 1 from pg_catalog.pg_timezone_names where name = tz) then
        tz := 'UTC';
    end if;

    select * into s from public.user_streaks where user_id = uid for update;
    if not found then
        insert into public.user_streaks (user_id, current_streak, longest_streak, last_visit)
        values (uid, 1, 1, now()) returning * into s;
    else
        today := (now() at time zone tz)::date;
        last_day := (s.last_visit at time zone tz)::date;
        if last_day = today then
            if s.current_streak = 0 then
                s.current_streak := 1;
            end if;
        elsif last_day = today - 1 then
            s.current_streak := s.current_streak + 1;
        else
            s.current_streak := 1;
        end if;
        update public.user_streaks
        set current_streak = s.current_streak,
            longest_streak = greatest(s.longest_streak, s.current_streak),
            last_visit = now()
        where id = s.id
        returning * into s;
    end if;

    return jsonb_build_object(
        'current_streak', s.current_streak,
        'longest_streak', s.longest_streak
    );
end;
$$;

-- Everything the home/account screens need about the user, in one call.
create or replace function public.get_my_profile()
returns jsonb language sql stable security definer set search_path = '' as $$
    select jsonb_build_object(
        'id', u.id,
        'name', u.name,
        'email', u.email,
        'age', u.age,
        'level', u.level,
        'payment_plan', u.payment_plan,
        'total_points', u.total_points,
        'joined_at', u.joined_at,
        'current_level_min_points', public.level_min_points(u.level::int),
        'next_level_min_points', public.level_min_points(u.level::int + 1),
        'current_streak', coalesce(st.current_streak, 0),
        'longest_streak', coalesce(st.longest_streak, 0),
        'completed_quizzes', (
            select count(*) from public.user_quiz_sessions
            where user_id = u.id and status = 'completed'),
        'in_progress_quizzes', (
            select count(*) from public.user_quiz_sessions
            where user_id = u.id and status = 'in_progress')
    )
    from public.users u
    left join public.user_streaks st on st.user_id = u.id
    where u.id = auth.uid();
$$;

-- Topics with the caller's progress, paginated.
create or replace function public.get_topics_with_progress(
    p_limit integer default 20, p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
    select coalesce(jsonb_agg(t order by t_id), '[]'::jsonb)
    from (
        select
            tp.id as t_id,
            jsonb_build_object(
                'id', tp.id,
                'name', tp.name,
                'quiz_count', (select count(*) from public.quizzes q where q.topic_id = tp.id),
                'completed_quiz_count', (
                    select count(distinct s.quiz_id)
                    from public.user_quiz_sessions s
                    join public.quizzes q on q.id = s.quiz_id
                    where q.topic_id = tp.id and s.user_id = auth.uid() and s.status = 'completed'),
                'total_points', (
                    select coalesce(sum(q.total_points), 0)
                    from public.quizzes q where q.topic_id = tp.id),
                'earned_points', (
                    select coalesce(sum(s.points_earned), 0)
                    from public.user_quiz_sessions s
                    join public.quizzes q on q.id = s.quiz_id
                    where q.topic_id = tp.id and s.user_id = auth.uid() and s.status = 'completed')
            ) as t
        from public.topics tp
        order by tp.id
        limit greatest(1, least(coalesce(p_limit, 20), 100))
        offset greatest(0, coalesce(p_offset, 0))
    ) x;
$$;

-- Quizzes the caller has never started or completed, optionally for one topic.
create or replace function public.get_available_quizzes(
    p_topic_id bigint default null, p_limit integer default 20, p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
    select coalesce(jsonb_agg(public.quiz_json(x.id) order by x.id), '[]'::jsonb)
    from (
        select q.id
        from public.quizzes q
        where (p_topic_id is null or q.topic_id = p_topic_id)
          and exists (select 1 from public.questions qu where qu.quiz_id = q.id)
          and not exists (
              select 1 from public.user_quiz_sessions s
              where s.user_id = auth.uid() and s.quiz_id = q.id
                and s.status in ('in_progress', 'completed'))
        order by q.id
        limit greatest(1, least(coalesce(p_limit, 20), 100))
        offset greatest(0, coalesce(p_offset, 0))
    ) x;
$$;

-- The caller's sessions with their full quiz, newest first.
-- p_status: 'in_progress' or 'completed'.
create or replace function public.get_my_sessions(
    p_status text,
    p_topic_id bigint default null,
    p_limit integer default 20,
    p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
    select coalesce(jsonb_agg(jsonb_build_object(
        'session', public.session_json(x.sess),
        'quiz', public.quiz_json((x.sess).quiz_id)
    ) order by x.sort_key desc), '[]'::jsonb)
    from (
        select s as sess, coalesce(s.completed_at, s.last_saved_at, s.started_at) as sort_key
        from public.user_quiz_sessions s
        join public.quizzes q on q.id = s.quiz_id
        where s.user_id = auth.uid()
          and s.status = p_status
          and (p_topic_id is null or q.topic_id = p_topic_id)
        order by coalesce(s.completed_at, s.last_saved_at, s.started_at) desc
        limit greatest(1, least(coalesce(p_limit, 20), 100))
        offset greatest(0, coalesce(p_offset, 0))
    ) x;
$$;

-- Starts a quiz. Idempotent: returns the existing in-progress session if any.
create or replace function public.start_quiz_session(p_quiz_id bigint)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
    uid uuid := auth.uid();
    s public.user_quiz_sessions;
    question_count integer;
begin
    if uid is null then
        raise exception 'Not authenticated' using errcode = '42501';
    end if;

    select * into s from public.user_quiz_sessions
    where user_id = uid and quiz_id = p_quiz_id and status = 'in_progress';
    if found then
        return public.session_json(s);
    end if;

    select count(*) into question_count from public.questions where quiz_id = p_quiz_id;
    if question_count = 0 then
        raise exception 'Quiz not found or has no questions' using errcode = 'P0002';
    end if;

    insert into public.user_quiz_sessions (user_id, quiz_id, total_questions, attempt_number)
    values (
        uid, p_quiz_id, question_count,
        coalesce((select max(attempt_number) from public.user_quiz_sessions
                  where user_id = uid and quiz_id = p_quiz_id), 0) + 1
    )
    returning * into s;

    return public.session_json(s);
end;
$$;

-- Saves answers so far. p_answers: [{"question_id": 1, "answer_id": 2}, ...]
create or replace function public.save_quiz_progress(p_session_id bigint, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
    s public.user_quiz_sessions;
    graded jsonb;
begin
    s := public.require_own_active_session(p_session_id);
    graded := public.grade_answers(s.quiz_id, p_answers);

    update public.user_quiz_sessions set
        answers = graded,
        answered_questions = jsonb_array_length(graded),
        correct_answers = (select count(*) from jsonb_array_elements(graded) e where (e->>'is_correct')::boolean),
        incorrect_answers = (select count(*) from jsonb_array_elements(graded) e where not (e->>'is_correct')::boolean),
        current_score = (select count(*) from jsonb_array_elements(graded) e where (e->>'is_correct')::boolean),
        last_saved_at = now(),
        updated_at = now()
    where id = s.id
    returning * into s;

    return public.session_json(s);
end;
$$;

-- Completes a quiz: grades on the server, awards points, updates level.
create or replace function public.complete_quiz_session(p_session_id bigint, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
    s public.user_quiz_sessions;
    graded jsonb;
    correct integer;
    quiz_points bigint;
    pct numeric(5,2);
    earned bigint;
    already_completed boolean;
    u public.users;
begin
    s := public.require_own_active_session(p_session_id);
    graded := public.grade_answers(s.quiz_id, p_answers);
    correct := (select count(*) from jsonb_array_elements(graded) e where (e->>'is_correct')::boolean);
    select total_points into quiz_points from public.quizzes where id = s.quiz_id;

    pct := case when s.total_questions > 0
                then round(correct::numeric * 100 / s.total_questions, 2) else 0 end;

    -- Points are awarded once per quiz, on the first completed attempt.
    select exists (
        select 1 from public.user_quiz_sessions
        where user_id = s.user_id and quiz_id = s.quiz_id and status = 'completed'
    ) into already_completed;
    earned := case when already_completed or s.total_questions = 0 then 0
                   else round(quiz_points::numeric * correct / s.total_questions)::bigint end;

    update public.user_quiz_sessions set
        answers = graded,
        status = 'completed',
        completed_at = now(),
        last_saved_at = now(),
        updated_at = now(),
        answered_questions = jsonb_array_length(graded),
        correct_answers = correct,
        incorrect_answers = jsonb_array_length(graded) - correct,
        current_score = correct,
        final_score = correct,
        percentage = pct,
        passed = pct >= 70,
        points_earned = earned,
        time_spent_seconds = extract(epoch from (now() - started_at))::bigint
    where id = s.id
    returning * into s;

    update public.users set
        total_points = total_points + earned,
        level = public.level_for_points(total_points + earned)
    where id = s.user_id
    returning * into u;

    return jsonb_build_object(
        'session', public.session_json(s),
        'total_points', u.total_points,
        'level', u.level,
        'leveled_up', u.level > public.level_for_points(u.total_points - earned)
    );
end;
$$;

-- Gives up on an in-progress quiz so it can be started fresh later.
create or replace function public.abandon_quiz_session(p_session_id bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare s public.user_quiz_sessions;
begin
    s := public.require_own_active_session(p_session_id);
    update public.user_quiz_sessions
    set status = 'abandoned', updated_at = now()
    where id = s.id;
end;
$$;

-- Permanently deletes the caller's account and all their data (App Store 5.1.1(v)).
create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid();
begin
    if uid is null then
        raise exception 'Not authenticated' using errcode = '42501';
    end if;
    delete from auth.users where id = uid; -- cascades to users, streaks, sessions
end;
$$;

-- ===========================================================================
-- 7. Maintenance (cron only)
-- ===========================================================================

create or replace function public.mark_abandoned_sessions()
returns integer language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
    update public.user_quiz_sessions
    set status = 'abandoned', updated_at = now()
    where status = 'in_progress' and last_saved_at < now() - interval '30 days';
    get diagnostics n = row_count;
    return n;
end;
$$;

select cron.schedule('daily-abandon-stale-sessions', '15 3 * * *', 'select public.mark_abandoned_sessions();');

-- ===========================================================================
-- 8. Function privileges
-- ===========================================================================

-- Nothing in public is callable by default…
revoke execute on all functions in schema public from public, anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

-- …except the client API, for signed-in users only.
grant execute on function
    public.check_in(text),
    public.get_my_profile(),
    public.get_topics_with_progress(integer, integer),
    public.get_available_quizzes(bigint, integer, integer),
    public.get_my_sessions(text, bigint, integer, integer),
    public.start_quiz_session(bigint),
    public.save_quiz_progress(bigint, jsonb),
    public.complete_quiz_session(bigint, jsonb),
    public.abandon_quiz_session(bigint),
    public.delete_my_account()
to authenticated;
