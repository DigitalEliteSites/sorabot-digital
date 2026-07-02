-- ============================================================
--  Sorabot Digital — Configuration de la base de données
--  À coller dans Supabase : SQL Editor > New query > Run
--  ⚠️ Remplace 'VOTRE-EMAIL-ADMIN@exemple.com' par l'email
--     exact de TON compte admin (celui créé dans Authentication).
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
  admin_note text,
  details jsonb
);

-- 2) Sécurité : Row Level Security activée
alter table public.orders enable row level security;

-- 2a) Les CLIENTS (anonymes) peuvent UNIQUEMENT créer une commande
drop policy if exists "anon insert orders" on public.orders;
create policy "anon insert orders"
  on public.orders for insert
  to anon, authenticated
  with check (true);

-- 2b) SEUL l'admin (par son email) peut lire / modifier / supprimer.
--     ⚠️ IMPORTANT : "to authenticated using (true)" serait une FAILLE
--     (tout compte inscrit pourrait tout lire). On restreint à l'email admin.
drop policy if exists "auth read orders" on public.orders;
drop policy if exists "admin read orders" on public.orders;
create policy "admin read orders"
  on public.orders for select
  to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

drop policy if exists "auth update orders" on public.orders;
drop policy if exists "admin update orders" on public.orders;
create policy "admin update orders"
  on public.orders for update
  to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com')
  with check (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

drop policy if exists "auth delete orders" on public.orders;
drop policy if exists "admin delete orders" on public.orders;
create policy "admin delete orders"
  on public.orders for delete
  to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

-- 3) Temps réel
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

-- 4) ⚠️ À faire aussi dans le dashboard (Authentication > Providers > Email) :
--    DÉSACTIVER l'inscription publique ("Enable sign-ups" / disable_signup = true)
--    pour empêcher la création de comptes non désirés.
