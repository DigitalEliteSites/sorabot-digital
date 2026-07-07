-- ============================================================
--  SORABOT — Renforcement de sécurité (défense en profondeur)
--  À coller dans Supabase : SQL Editor > New query > Run
--
--  ✅ Version "rejouable" : tu peux la lancer autant de fois que
--     tu veux, elle ne donnera jamais d'erreur "already exists".
--  Sans danger : limite la TAILLE des données qu'un client peut
--  insérer (anti-spam / anti-abus). N'affecte pas les commandes
--  déjà existantes (clause NOT VALID).
-- ============================================================

alter table public.orders drop constraint if exists orders_ref_len;
alter table public.orders add  constraint orders_ref_len      check (ref is null or char_length(ref) <= 40)          not valid;

alter table public.orders drop constraint if exists orders_prenom_len;
alter table public.orders add  constraint orders_prenom_len   check (prenom is null or char_length(prenom) <= 80)    not valid;

alter table public.orders drop constraint if exists orders_nom_len;
alter table public.orders add  constraint orders_nom_len      check (nom is null or char_length(nom) <= 80)          not valid;

alter table public.orders drop constraint if exists orders_email_len;
alter table public.orders add  constraint orders_email_len    check (email is null or char_length(email) <= 120)     not valid;

alter table public.orders drop constraint if exists orders_whatsapp_len;
alter table public.orders add  constraint orders_whatsapp_len check (whatsapp is null or char_length(whatsapp) <= 40) not valid;

alter table public.orders drop constraint if exists orders_notes_len;
alter table public.orders add  constraint orders_notes_len    check (notes is null or char_length(notes) <= 2000)    not valid;

alter table public.orders drop constraint if exists orders_proof_size;
alter table public.orders add  constraint orders_proof_size   check (proof is null or char_length(proof) <= 3000000) not valid;  -- ~2 Mo max/preuve

alter table public.orders drop constraint if exists orders_total_pos;
alter table public.orders add  constraint orders_total_pos    check (total_eur is null or total_eur >= 0)            not valid;

-- ============================================================
--  ⚠️  À FAIRE AUSSI dans le dashboard Supabase (hors SQL) :
--   1) Authentication > Providers > Email : DÉSACTIVER "Enable sign-ups".
--   2) Ton compte admin Supabase : mot de passe FORT + activer la 2FA.
-- ============================================================
