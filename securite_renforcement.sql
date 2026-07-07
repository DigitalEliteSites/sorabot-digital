-- ============================================================
--  SORABOT — Renforcement de sécurité (défense en profondeur)
--  À coller dans Supabase : SQL Editor > New query > Run
--
--  Sans danger : ces règles limitent la TAILLE des données qu'un
--  client peut insérer (anti-spam / anti-abus). Elles n'affectent
--  PAS les commandes déjà existantes (clause NOT VALID).
-- ============================================================

-- Bornes de taille sur les commandes (empêche les insertions abusives / le gonflage de la base)
alter table public.orders add constraint orders_ref_len      check (ref is null or char_length(ref) <= 40)          not valid;
alter table public.orders add constraint orders_prenom_len   check (prenom is null or char_length(prenom) <= 80)    not valid;
alter table public.orders add constraint orders_nom_len      check (nom is null or char_length(nom) <= 80)          not valid;
alter table public.orders add constraint orders_email_len    check (email is null or char_length(email) <= 120)     not valid;
alter table public.orders add constraint orders_whatsapp_len check (whatsapp is null or char_length(whatsapp) <= 40) not valid;
alter table public.orders add constraint orders_notes_len    check (notes is null or char_length(notes) <= 2000)    not valid;
alter table public.orders add constraint orders_proof_size   check (proof is null or char_length(proof) <= 3000000) not valid;  -- ~2 Mo max par preuve
alter table public.orders add constraint orders_total_pos    check (total_eur is null or total_eur >= 0)            not valid;

-- (Les avis ont déjà leurs contraintes serveur : prénom 1-50, note 0-10, commentaire <= 500.)

-- ============================================================
--  ⚠️  À FAIRE AUSSI dans le dashboard Supabase (hors SQL) :
--
--   1) Authentication > Providers > Email :
--        DÉSACTIVER « Enable sign-ups »
--        (pour que PERSONNE ne puisse créer de compte).
--
--   2) Ton compte admin Supabase :
--        - mot de passe FORT et unique
--        - activer la double authentification (2FA)
--
--   C'est ce compte qui protège toutes les données de tes clients.
-- ============================================================
