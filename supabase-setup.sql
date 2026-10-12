-- JASHxp shared game portfolio: Supabase SQL setup
-- Run this entire file in Supabase Dashboard > SQL Editor > New query.

create extension if not exists pgcrypto;

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  status text not null check (status in ('finished', 'ongoing', 'upcoming')),
  category text not null default 'Game',
  image_url text,
  logo_url text,
  links jsonb not null default '[]'::jsonb check (jsonb_typeof(links) = 'array'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.games enable row level security;
alter table public.admin_users enable row level security;

-- Public visitors may read the game list. All writes require the authorized admin.
drop policy if exists "Anyone can read games" on public.games;
create policy "Anyone can read games" on public.games
  for select to anon, authenticated using (true);

create or replace function public.is_portfolio_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_users au where au.user_id = auth.uid()
  );
$$;

revoke all on function public.is_portfolio_admin() from public;
grant execute on function public.is_portfolio_admin() to authenticated;

drop policy if exists "Admins can insert games" on public.games;
create policy "Admins can insert games" on public.games
  for insert to authenticated with check (public.is_portfolio_admin());

drop policy if exists "Admins can update games" on public.games;
create policy "Admins can update games" on public.games
  for update to authenticated using (public.is_portfolio_admin()) with check (public.is_portfolio_admin());

drop policy if exists "Admins can delete games" on public.games;
create policy "Admins can delete games" on public.games
  for delete to authenticated using (public.is_portfolio_admin());

-- An authenticated user can check only their own admin membership.
drop policy if exists "Admins can read own membership" on public.admin_users;
create policy "Admins can read own membership" on public.admin_users
  for select to authenticated using (user_id = auth.uid());

-- Seed the 20 games supplied for JASHxp. Re-running this script won't duplicate them.
insert into public.games (name, status, category) values
 ('Far Cry 2','finished','PC'),
 ('Far Cry 3','finished','PC'),
 ('Far Cry 4','finished','PC'),
 ('Far Cry 5','finished','PC'),
 ('Far Cry 6','finished','PC'),
 ('Far Cry Primal','finished','PC'),
 ('GTA III','finished','PC'),
 ('GTA: Liberty City Stories','finished','GTA'),
 ('GTA: Vice City','finished','PC'),
 ('GTA: San Andreas','finished','PC'),
 ('GTA IV','finished','PC'),
 ('GTA V','finished','PC'),
 ('Mad Max','finished','PC'),
 ('Need for Speed: Most Wanted','finished','Racing'),
 ('Halo','finished','FPS'),
 ('Call of Duty: Modern Warfare 4','finished','FPS'),
 ('PUBG','ongoing','Mobile'),
 ('BGMI','ongoing','Mobile'),
 ('Clash of Clans','ongoing','Mobile'),
 ('Clash Royale','ongoing','Mobile')
on conflict (name) do nothing;

-- Enable realtime updates for visitors (safe to run repeatedly).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'games'
  ) then
    alter publication supabase_realtime add table public.games;
  end if;
end $$;

-- ADMIN SETUP (do this AFTER creating your admin account in Authentication):
-- 1. Open Authentication > Users and copy the new user's UUID.
-- 2. Replace YOUR_AUTH_USER_UUID below with that UUID, remove the leading --, and run it.
-- insert into public.admin_users (user_id) values ('YOUR_AUTH_USER_UUID') on conflict do nothing;
