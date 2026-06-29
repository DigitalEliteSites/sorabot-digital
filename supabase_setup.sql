-- ============================================================
--  Sorabot Digital — Configuration de la base de données
--  À coller dans Supabase : SQL Editor > New query > Run
-- ============================================================

-- 1) Table des commandes
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  ref text,
  prenom text,
  nom text,
  whatsapp text,
  email text,
  notes text,
  total_eur numeric default 0,
  currency text,
  price_local text,
  selections jsonb,
  items jsonb,
  proof text,
  status text default 'En attente',
  admin_note text
);

-- 2) Sécurité : on active la Row Level Security
alter table public.orders enable row level security;

-- 2a) Les CLIENTS (anonymes) peuvent UNIQUEMENT créer une commande
drop policy if exists "anon insert orders" on public.orders;
create policy "anon insert orders"
  on public.orders for insert
  to anon
  with check (true);

-- 2b) Seul l'ADMIN connecté peut lire / modifier / supprimer
drop policy if exists "auth read orders" on public.orders;
create policy "auth read orders"
  on public.orders for select
  to authenticated using (true);

drop policy if exists "auth update orders" on public.orders;
create policy "auth update orders"
  on public.orders for update
  to authenticated using (true) with check (true);

drop policy if exists "auth delete orders" on public.orders;
create policy "auth delete orders"
  on public.orders for delete
  to authenticated using (true);

-- 3) Temps réel : on ajoute la table au flux realtime
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'orders'
  ) then
    execute 'alter publication supabase_realtime add table public.orders';
  end if;
end $$;

-- ✅ Terminé. Tu peux fermer cet onglet et revenir au site.
