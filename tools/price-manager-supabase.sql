-- SmartEye Price Manager — Supabase tables.
-- Supabase → SQL Editor → New query → paste everything → Run.
-- Safe to run more than once.

-- Supplier price lists (one row per supplier: Hikvision, Dahua, ...)
create table if not exists public.price_lists (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  file text,
  date text,
  items jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  unique (user_id, name)
);

-- Settings: service prices, signature, markup, exchange rate
create table if not exists public.pm_settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Saved quotes (history)
create table if not exists public.quotes (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client text,
  total numeric not null default 0,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists quotes_user_created_idx on public.quotes (user_id, created_at desc);

alter table public.price_lists enable row level security;
alter table public.pm_settings enable row level security;
alter table public.quotes      enable row level security;

-- Only the signed-in owner can see or change their own rows
drop policy if exists own_rows on public.price_lists;
create policy own_rows on public.price_lists for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists own_rows on public.pm_settings;
create policy own_rows on public.pm_settings for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists own_rows on public.quotes;
create policy own_rows on public.quotes for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Anonymous visitors get nothing
revoke all on public.price_lists, public.pm_settings, public.quotes from anon;
