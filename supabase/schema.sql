-- =====================================================================
-- Intima Partner Mode (Фаза 7) — схема + RLS за Supabase
-- Изпълни ЦЕЛИЯ файл в Dashboard → SQL Editor → Run.
-- Сървърът вижда само публични ключове и шифровани блокчета (base64).
-- =====================================================================

create extension if not exists pgcrypto;

-- Двойка: две анонимни auth идентичности. Нищо лично.
create table if not exists public.couples (
  id uuid primary key default gen_random_uuid(),
  member_a uuid not null,
  member_b uuid not null,
  created_at timestamptz not null default now()
);

-- Еднократна покана: живее 15 минути, носи само публични ключове.
create table if not exists public.pairings (
  code text primary key,
  pub_a text not null,
  pub_b text,
  member_a uuid not null,
  member_b uuid,
  couple_id uuid references public.couples(id) on delete cascade,
  confirmations int not null default 0,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '15 minutes'
);

-- Споделен запис: единствената нешифрована семантика е kind.
create table if not exists public.shared_items (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid not null references public.couples(id) on delete cascade,
  author uuid not null,
  kind smallint not null,
  nonce text not null,
  cipher text not null,
  mac text not null,
  created_at timestamptz not null default now()
);

create index if not exists shared_items_couple_created
  on public.shared_items (couple_id, created_at);

-- ---------------------------------------------------------------------
-- Row Level Security: всичко е заключено; достъпът е само през
-- политиките и security definer функциите по-долу.
-- ---------------------------------------------------------------------
alter table public.couples enable row level security;
alter table public.pairings enable row level security;
alter table public.shared_items enable row level security;

drop policy if exists couples_select on public.couples;
create policy couples_select on public.couples
  for select using (auth.uid() in (member_a, member_b));

drop policy if exists items_select on public.shared_items;
create policy items_select on public.shared_items
  for select using (exists (
    select 1 from public.couples c
    where c.id = couple_id and auth.uid() in (c.member_a, c.member_b)));

drop policy if exists items_insert on public.shared_items;
create policy items_insert on public.shared_items
  for insert with check (
    author = auth.uid() and exists (
      select 1 from public.couples c
      where c.id = couple_id and auth.uid() in (c.member_a, c.member_b)));

-- pairings нямат политики → директен достъп няма; само функциите.

-- ---------------------------------------------------------------------
-- Функции за сдвояването (security definer = минават покрай RLS,
-- но винаги проверяват auth.uid()).
-- ---------------------------------------------------------------------

create or replace function public.create_pairing(p_code text, p_pub_a text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  delete from pairings where expires_at < now();
  insert into pairings (code, pub_a, member_a)
  values (p_code, p_pub_a, auth.uid());
end $$;

create or replace function public.join_pairing(p_code text, p_pub_b text)
returns text
language plpgsql security definer set search_path = public as $$
declare v_pub_a text;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  update pairings
     set pub_b = p_pub_b, member_b = auth.uid()
   where code = p_code
     and pub_b is null
     and expires_at > now()
     and member_a <> auth.uid()
  returning pub_a into v_pub_a;
  return v_pub_a;  -- null = непознат / зает / изтекъл код
end $$;

create or replace function public.pairing_state(p_code text)
returns text
language plpgsql security definer set search_path = public as $$
declare v_pub_b text;
begin
  select pub_b into v_pub_b
    from pairings
   where code = p_code and member_a = auth.uid();
  return v_pub_b;  -- null = още никой не е приел
end $$;

create or replace function public.complete_pairing(p_code text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare v_row pairings;
begin
  select * into v_row from pairings
   where code = p_code
     and auth.uid() in (member_a, member_b)
     and pub_b is not null;
  if not found then raise exception 'unknown pairing'; end if;

  if v_row.couple_id is null then
    insert into couples (member_a, member_b)
    values (v_row.member_a, v_row.member_b)
    returning id into v_row.couple_id;
    update pairings set couple_id = v_row.couple_id where code = p_code;
  end if;

  update pairings set confirmations = confirmations + 1 where code = p_code;
  -- И двамата потвърдиха → поканата изчезва (двойката остава).
  delete from pairings where code = p_code and confirmations >= 2;
  return v_row.couple_id;
end $$;

create or replace function public.dissolve_couple(p_couple uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  -- on delete cascade чисти и shared_items.
  delete from couples
   where id = p_couple and auth.uid() in (member_a, member_b);
end $$;

-- Функциите са достъпни само за влезли (вкл. анонимни) потребители.
revoke execute on function public.create_pairing(text, text) from anon, public;
revoke execute on function public.join_pairing(text, text) from anon, public;
revoke execute on function public.pairing_state(text) from anon, public;
revoke execute on function public.complete_pairing(text) from anon, public;
revoke execute on function public.dissolve_couple(uuid) from anon, public;
grant execute on function public.create_pairing(text, text) to authenticated;
grant execute on function public.join_pairing(text, text) to authenticated;
grant execute on function public.pairing_state(text) to authenticated;
grant execute on function public.complete_pairing(text) to authenticated;
grant execute on function public.dissolve_couple(uuid) to authenticated;
