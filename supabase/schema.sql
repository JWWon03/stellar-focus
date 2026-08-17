-- =====================================================================
-- Stellar Focus — 계정 / 클라우드 저장 스키마
--
-- Supabase 대시보드 → SQL Editor 에 이 파일 전체를 붙여넣고 Run 하세요.
-- 여러 번 실행해도 안전합니다.
--
-- 설계 요지
--   · 테이블은 RLS로 잠그고 정책을 하나도 만들지 않는다 → anon 키로는
--     테이블에 직접 접근할 수 없다. 오직 아래 함수들로만 드나든다.
--   · PIN은 bcrypt로 해싱한다 (자릿수가 짧으니 반드시 느린 해시여야 한다).
--   · 로그인 성공 시 발급하는 토큰은 엔트로피가 충분하므로 sha256으로 충분.
--   · PIN 10회 연속 실패 시 15분 잠금 — 4자리 PIN의 전수 대입을 막는 핵심 장치.
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.sf_saves (
  id            text primary key,
  pin_hash      text        not null,
  data          jsonb       not null default '{}'::jsonb,
  token_hash    text,
  token_expires timestamptz,
  fail_count    int         not null default 0,
  locked_until  timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- 정책 없이 RLS만 켠다 = anon/authenticated 모두 직접 접근 불가
alter table public.sf_saves enable row level security;
revoke all on public.sf_saves from anon, authenticated;

-- ---------------------------------------------------------------------
-- 내부 헬퍼
-- ---------------------------------------------------------------------
create or replace function public.sf__token_ok(p_row public.sf_saves, p_token text)
returns boolean
language sql immutable
as $$
  select p_row.token_hash is not null
     and p_row.token_expires > now()
     and p_row.token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex');
$$;

-- ---------------------------------------------------------------------
-- 가입
-- ---------------------------------------------------------------------
create or replace function public.sf_signup(p_id text, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_token text;
begin
  if p_id is null or p_id !~ '^[A-Za-z0-9_-]{3,16}$' then
    return jsonb_build_object('ok', false, 'error', 'id_format');
  end if;
  if p_pin is null or p_pin !~ '^[0-9]{4,6}$' then
    return jsonb_build_object('ok', false, 'error', 'pin_format');
  end if;
  if exists (select 1 from public.sf_saves where id = p_id) then
    return jsonb_build_object('ok', false, 'error', 'taken');
  end if;

  v_token := encode(gen_random_bytes(24), 'hex');

  insert into public.sf_saves (id, pin_hash, token_hash, token_expires)
  values (p_id,
          crypt(p_pin, gen_salt('bf')),
          encode(digest(v_token, 'sha256'), 'hex'),
          now() + interval '90 days');

  return jsonb_build_object('ok', true, 'token', v_token, 'data', '{}'::jsonb);
end;
$$;

-- ---------------------------------------------------------------------
-- 로그인
-- ---------------------------------------------------------------------
create or replace function public.sf_login(p_id text, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  r       public.sf_saves%rowtype;
  v_token text;
  v_fails int;
begin
  select * into r from public.sf_saves where id = p_id;
  if not found then
    -- 존재 여부를 흘리지 않도록 PIN 오류와 같은 응답을 준다
    return jsonb_build_object('ok', false, 'error', 'bad_login');
  end if;

  if r.locked_until is not null and r.locked_until > now() then
    return jsonb_build_object('ok', false, 'error', 'locked',
                              'seconds', ceil(extract(epoch from (r.locked_until - now()))));
  end if;

  if r.pin_hash <> crypt(p_pin, r.pin_hash) then
    v_fails := r.fail_count + 1;
    update public.sf_saves
       set fail_count   = case when v_fails >= 10 then 0 else v_fails end,
           locked_until = case when v_fails >= 10 then now() + interval '15 minutes' else null end
     where id = p_id;
    return jsonb_build_object('ok', false, 'error', 'bad_login',
                              'left', greatest(0, 10 - v_fails));
  end if;

  v_token := encode(gen_random_bytes(24), 'hex');
  update public.sf_saves
     set token_hash    = encode(digest(v_token, 'sha256'), 'hex'),
         token_expires = now() + interval '90 days',
         fail_count    = 0,
         locked_until  = null
   where id = p_id;

  return jsonb_build_object('ok', true, 'token', v_token,
                            'data', r.data, 'updated_at', r.updated_at);
end;
$$;

-- ---------------------------------------------------------------------
-- 불러오기
-- ---------------------------------------------------------------------
create or replace function public.sf_pull(p_id text, p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  r public.sf_saves%rowtype;
begin
  select * into r from public.sf_saves where id = p_id;
  if not found or not public.sf__token_ok(r, p_token) then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;
  return jsonb_build_object('ok', true, 'data', r.data, 'updated_at', r.updated_at);
end;
$$;

-- ---------------------------------------------------------------------
-- 저장
-- ---------------------------------------------------------------------
create or replace function public.sf_push(p_id text, p_token text, p_data jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  r public.sf_saves%rowtype;
begin
  select * into r from public.sf_saves where id = p_id;
  if not found or not public.sf__token_ok(r, p_token) then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;
  -- 저장 용량 보호 (항성계 데이터는 수 KB 수준이다)
  if octet_length(p_data::text) > 200000 then
    return jsonb_build_object('ok', false, 'error', 'too_large');
  end if;

  update public.sf_saves
     set data = p_data, updated_at = now()
   where id = p_id;

  return jsonb_build_object('ok', true, 'updated_at', now());
end;
$$;

-- ---------------------------------------------------------------------
-- PIN 변경
-- ---------------------------------------------------------------------
create or replace function public.sf_change_pin(p_id text, p_token text, p_old text, p_new text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  r public.sf_saves%rowtype;
begin
  select * into r from public.sf_saves where id = p_id;
  if not found or not public.sf__token_ok(r, p_token) then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;
  if r.pin_hash <> crypt(p_old, r.pin_hash) then
    return jsonb_build_object('ok', false, 'error', 'bad_login');
  end if;
  if p_new is null or p_new !~ '^[0-9]{4,6}$' then
    return jsonb_build_object('ok', false, 'error', 'pin_format');
  end if;
  update public.sf_saves set pin_hash = crypt(p_new, gen_salt('bf')) where id = p_id;
  return jsonb_build_object('ok', true);
end;
$$;

-- ---------------------------------------------------------------------
-- 권한: 함수만 열어준다
-- ---------------------------------------------------------------------
revoke all on function public.sf__token_ok(public.sf_saves, text) from public, anon, authenticated;

grant execute on function public.sf_signup(text, text)                     to anon, authenticated;
grant execute on function public.sf_login(text, text)                      to anon, authenticated;
grant execute on function public.sf_pull(text, text)                       to anon, authenticated;
grant execute on function public.sf_push(text, text, jsonb)                to anon, authenticated;
grant execute on function public.sf_change_pin(text, text, text, text)     to anon, authenticated;
