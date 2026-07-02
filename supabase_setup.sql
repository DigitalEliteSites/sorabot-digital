-- ============================================================
--  Sorabot Digital — Configuration de la base de données
--  À coller dans Supabase : SQL Editor > New query > Run
--  ⚠️ Remplace 'VOTRE-EMAIL-ADMIN@exemple.com' par l'email
--     exact de TON compte admin (celui créé dans Authentication).
-- ============================================================

-- =========================  COMMANDES  =========================

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
drop policy if exists "auth read orders" on public.orders;
drop policy if exists "admin read orders" on public.orders;
create policy "admin read orders"
  on public.orders for select to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

drop policy if exists "auth update orders" on public.orders;
drop policy if exists "admin update orders" on public.orders;
create policy "admin update orders"
  on public.orders for update to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com')
  with check (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

drop policy if exists "auth delete orders" on public.orders;
drop policy if exists "admin delete orders" on public.orders;
create policy "admin delete orders"
  on public.orders for delete to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

-- =========================  AVIS CLIENTS  =========================

-- 3) Table des avis (AUCUN champ email/téléphone : données non sensibles)
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  prenom text not null,
  rating int not null,
  comment text,
  status text not null default 'pending',
  -- Contraintes SERVEUR (pas seulement côté client) :
  constraint reviews_prenom_len check (char_length(prenom) between 1 and 50),
  constraint reviews_rating_range check (rating between 0 and 10),
  constraint reviews_comment_len check (comment is null or char_length(comment) <= 500),
  constraint reviews_status_valid check (status in ('pending','approved','rejected'))
);

-- 4) Sécurité RLS des avis
alter table public.reviews enable row level security;

-- 4a) INSERT anonyme : autorisé UNIQUEMENT en statut 'pending'
--     (un client ne peut pas publier un avis déjà "approved")
drop policy if exists "anon insert reviews" on public.reviews;
create policy "anon insert reviews"
  on public.reviews for insert
  to anon, authenticated
  with check (status = 'pending');

-- 4b) SELECT public : uniquement les avis APPROUVÉS
drop policy if exists "public read approved reviews" on public.reviews;
create policy "public read approved reviews"
  on public.reviews for select
  to anon, authenticated
  using (status = 'approved');

-- 4c) SELECT admin : l'admin voit TOUS les avis (pour modérer)
drop policy if exists "admin read reviews" on public.reviews;
create policy "admin read reviews"
  on public.reviews for select to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

-- 4d) UPDATE / DELETE : réservés à l'admin
drop policy if exists "admin update reviews" on public.reviews;
create policy "admin update reviews"
  on public.reviews for update to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com')
  with check (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

drop policy if exists "admin delete reviews" on public.reviews;
create policy "admin delete reviews"
  on public.reviews for delete to authenticated
  using (auth.jwt() ->> 'email' = 'VOTRE-EMAIL-ADMIN@exemple.com');

-- =========================  TEMPS RÉEL  =========================
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='orders') then
    execute 'alter publication supabase_realtime add table public.orders';
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='reviews') then
    execute 'alter publication supabase_realtime add table public.reviews';
  end if;
end $$;

-- ⚠️ À faire aussi dans le dashboard (Authentication > Providers > Email) :
--    DÉSACTIVER l'inscription publique ("Enable sign-ups" / disable_signup = true).
