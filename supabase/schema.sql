-- =====================================================================
-- Intima Partner Mode (Фаза 7) — схема за чат с медия (без E2E)
-- Изпълни ЦЕЛИЯ файл в Dashboard → SQL Editor → Run.
-- Re-runnable: дропва старите обекти и ги пресъздава.
--
-- ВАЖНО: партньорският чат, снимките и видеата се пазят на сървъра в
-- явен вид и може да бъдат преглеждани (модерация/злоупотреби). Това
-- е оповестено в Privacy Policy и Play Data Safety. Личният дневник и
-- календар остават само на устройството.
-- =====================================================================

-- Чистим старата (E2E) схема, ако е пускана.
drop table if exists public.shared_items cascade;
drop function if exists public.create_pairing(text, text);
drop function if exists public.join_pairing(text, text);
drop function if exists public.pairing_state(text);
drop function if exists public.complete_pairing(text);

-- Двойка: две анонимни auth идентичности. Един потребител може да е в
-- няколко двойки (няколко партньора).
create table if not exists public.couples (
  id uuid primary key default gen_random_uuid(),
  member_a uuid not null,
  member_b uuid not null,
  created_at timestamptz not null default now()
);

-- Еднократна покана: живее 15 минути.
create table if not exists public.pairings (
  code text primary key,
  inviter uuid not null,
  couple_id uuid references public.couples(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '15 minutes'
);

-- Чат съобщение: текст и/или медия (път в Storage). Без криптиране.
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid not null references public.couples(id) on delete cascade,
  author uuid not null,
  body text,
  media_path text,
  media_kind smallint not null default 0,   -- 0 няма, 1 снимка, 2 видео
  created_at timestamptz not null default now()
);

create index if not exists messages_couple_created
  on public.messages (couple_id, created_at);

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------
alter table public.couples enable row level security;
alter table public.pairings enable row level security;
alter table public.messages enable row level security;

drop policy if exists couples_select on public.couples;
create policy couples_select on public.couples
  for select to authenticated
  using (auth.uid() in (member_a, member_b));

drop policy if exists messages_select on public.messages;
create policy messages_select on public.messages
  for select to authenticated
  using (exists (
    select 1 from public.couples c
    where c.id = couple_id and auth.uid() in (c.member_a, c.member_b)));

drop policy if exists messages_insert on public.messages;
create policy messages_insert on public.messages
  for insert to authenticated
  with check (author = auth.uid() and exists (
    select 1 from public.couples c
    where c.id = couple_id and auth.uid() in (c.member_a, c.member_b)));

-- pairings нямат политики → достъп само през функциите по-долу.

-- ---------------------------------------------------------------------
-- Storage bucket за снимки/видеа (частен; достъп през RLS).
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('partner-media', 'partner-media', false)
on conflict (id) do nothing;

drop policy if exists partner_media_select on storage.objects;
create policy partner_media_select on storage.objects
  for select to authenticated
  using (bucket_id = 'partner-media' and (storage.foldername(name))[1]::uuid in (
    select id from public.couples where auth.uid() in (member_a, member_b)));

drop policy if exists partner_media_insert on storage.objects;
create policy partner_media_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'partner-media' and (storage.foldername(name))[1]::uuid in (
    select id from public.couples where auth.uid() in (member_a, member_b)));

-- ---------------------------------------------------------------------
-- Функции за сдвояването (security definer, винаги проверяват auth.uid()).
-- ---------------------------------------------------------------------

create or replace function public.create_pairing(p_code text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  delete from pairings where expires_at < now();
  insert into pairings (code, inviter) values (p_code, auth.uid());
end $$;

-- Приема покана: създава двойката и връща couple_id (или null).
create or replace function public.join_pairing(p_code text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare v_inviter uuid; v_couple uuid;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  select inviter into v_inviter from pairings
   where code = p_code and couple_id is null and expires_at > now()
     and inviter <> auth.uid();
  if v_inviter is null then return null; end if;
  insert into couples (member_a, member_b)
  values (v_inviter, auth.uid()) returning id into v_couple;
  update pairings set couple_id = v_couple where code = p_code;
  return v_couple;
end $$;

-- Канещият пита дали поканата е приета → връща couple_id (или null).
create or replace function public.pairing_couple(p_code text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare v_couple uuid;
begin
  select couple_id into v_couple from pairings
   where code = p_code and inviter = auth.uid();
  return v_couple;
end $$;

create or replace function public.dissolve_couple(p_couple uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  delete from couples
   where id = p_couple and auth.uid() in (member_a, member_b);
end $$;

revoke execute on function public.create_pairing(text) from anon, public;
revoke execute on function public.join_pairing(text) from anon, public;
revoke execute on function public.pairing_couple(text) from anon, public;
revoke execute on function public.dissolve_couple(uuid) from anon, public;
grant execute on function public.create_pairing(text) to authenticated;
grant execute on function public.join_pairing(text) to authenticated;
grant execute on function public.pairing_couple(text) to authenticated;
grant execute on function public.dissolve_couple(uuid) to authenticated;
