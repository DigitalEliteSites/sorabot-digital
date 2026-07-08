-- ============================================================
--  SORABOT — SÉCURITÉ « BÉTON ARMÉ »  (à exécuter dans Supabase)
--  SQL Editor > New query > Coller > Run.
--  Sans danger : ne casse rien, ne fait que RENFORCER.
-- ============================================================

-- 1) RLS ACTIVÉE + FORCÉE sur toutes les tables
--    FORCE = même le rôle propriétaire de la table ne peut PLUS
--    contourner la RLS (verrou supplémentaire, "défense en profondeur").
alter table public.orders          enable row level security;
alter table public.orders          force  row level security;
alter table public.reviews         enable row level security;
alter table public.reviews         force  row level security;
alter table public.discount_codes  enable row level security;
alter table public.discount_codes  force  row level security;

-- 2) Verrouiller la fonction de validation des codes : usage minimal
--    (elle ne renvoie QUE la remise + les produits, jamais la commission)
revoke all on function public.validate_discount_code(text) from public;
grant execute on function public.validate_discount_code(text) to anon, authenticated;

-- 3) Aucune permission par défaut au public sur d'éventuelles NOUVELLES tables
--    (si un jour tu ajoutes une table, elle ne sera pas exposée par accident)
alter default privileges in schema public revoke all on tables from anon;
alter default privileges in schema public revoke all on tables from authenticated;

-- ============================================================
--  4) (OPTIONNEL - défense en profondeur) TEMPS RÉEL
--     La RLS protège déjà le temps réel : un visiteur anonyme qui
--     s'abonne à "orders" ne reçoit RIEN (la RLS filtre). Mais si tu
--     veux le verrou ABSOLU (l'admin passera de "instantané" à
--     "rafraîchi toutes les 25s"), décommente ces 2 lignes :
--
--   -- alter publication supabase_realtime drop table public.orders;
--   -- alter publication supabase_realtime drop table public.reviews;
-- ============================================================

-- ============================================================
--  ⚠️  À FAIRE DANS LE DASHBOARD SUPABASE (le plus important) :
--   Authentication > Sign In / Providers :
--     - "Enable Captcha protection" = ON (Cloudflare Turnstile)
--   Authentication > Policies / Settings :
--     - "Leaked password protection" = ON
--     - Vérifier les "Rate limits" de connexion (bas)
--   Le compte admin :
--     - mot de passe TRÈS fort et UNIQUE
--     - email admin NON évident (PAS l'email public du business)
--     - activer la 2FA / MFA
-- ============================================================
