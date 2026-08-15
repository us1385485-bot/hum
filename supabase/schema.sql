-- ============================================================================
-- IDEAL SPORTS — Supabase Database Schema + RLS Policies
-- Run this entire script in: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONS (optional, for UUID support if needed)
-- ============================================================================
create extension if not exists "uuid-ossp";

-- ============================================================================
-- 2. TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 TEAMS — matches the club grid on teams.html
-- Fields: name, short_code (crest initials), league
-- ----------------------------------------------------------------------------
create table if not exists public.teams (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  short_code text not null,
  league text not null,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.2 PLAYERS — matches the player grid + modal on teams.html
-- Fields: name, team_id (FK), position (GK/DF/MF/FW), goals, assists,
--         appearances, bio, initials
-- ----------------------------------------------------------------------------
create table if not exists public.players (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  team_id uuid references public.teams(id) on delete cascade,
  position text not null check (position in ('GK', 'DF', 'MF', 'FW')),
  goals integer not null default 0,
  assists integer not null default 0,
  appearances integer not null default 0,
  bio text,
  initials text not null,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.3 FIXTURES — matches match cards on fixtures.html + live ticker on index.html
-- Fields: home/away team + code, scores, status (live/upcoming/finished),
--         league, kickoff, venue, minute (for live matches)
-- ----------------------------------------------------------------------------
create table if not exists public.fixtures (
  id uuid primary key default uuid_generate_v4(),
  home_team text not null,
  away_team text not null,
  home_team_code text not null,
  away_team_code text not null,
  home_score integer not null default 0,
  away_score integer not null default 0,
  status text not null check (status in ('live', 'upcoming', 'finished')),
  league text,
  kickoff timestamptz,
  venue text,
  minute integer not null default 0,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.4 HEAD_TO_HEAD — matches the expandable H2H drawers on fixtures.html
-- Fields: fixture_id (FK), meetings, home_wins, away_wins, draws,
--         home_goals, away_goals
-- ----------------------------------------------------------------------------
create table if not exists public.head_to_head (
  id uuid primary key default uuid_generate_v4(),
  fixture_id uuid references public.fixtures(id) on delete cascade,
  meetings integer not null default 0,
  home_wins integer not null default 0,
  away_wins integer not null default 0,
  draws integer not null default 0,
  home_goals integer not null default 0,
  away_goals integer not null default 0,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.5 NEWS — matches the featured news grid on index.html
-- Fields: title, excerpt, category, emoji (for thumb), read_time, published_at
-- ----------------------------------------------------------------------------
create table if not exists public.news (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  excerpt text not null,
  category text not null,
  emoji text not null default '⚽',
  read_time integer not null default 4,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.6 MESSAGES — contact form submissions from contact.html
-- Fields: name, email, subject, message
-- ----------------------------------------------------------------------------
create table if not exists public.messages (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  email text not null,
  subject text not null,
  message text not null,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2.7 SUBSCRIBERS — newsletter signups from index.html + contact.html
-- Fields: email (unique)
-- ----------------------------------------------------------------------------
create table if not exists public.subscribers (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  created_at timestamptz not null default now()
);

-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
alter table public.teams         enable row level security;
alter table public.players       enable row level security;
alter table public.fixtures      enable row level security;
alter table public.head_to_head  enable row level security;
alter table public.news          enable row level security;
alter table public.messages      enable row level security;
alter table public.subscribers   enable row level security;

-- ----------------------------------------------------------------------------
-- 3.1 PUBLIC READ POLICIES — anyone can SELECT display data
-- ----------------------------------------------------------------------------
create policy "teams are publicly readable"
  on public.teams for select
  using (true);

create policy "players are publicly readable"
  on public.players for select
  using (true);

create policy "fixtures are publicly readable"
  on public.fixtures for select
  using (true);

create policy "head_to_head is publicly readable"
  on public.head_to_head for select
  using (true);

create policy "news is publicly readable"
  on public.news for select
  using (true);

-- ----------------------------------------------------------------------------
-- 3.2 PUBLIC INSERT POLICIES — anyone can INSERT into forms
--     (but CANNOT read others' submissions)
-- ----------------------------------------------------------------------------
create policy "anyone can submit a message"
  on public.messages for insert
  with check (true);

create policy "anyone can subscribe to newsletter"
  on public.subscribers for insert
  with check (true);

-- ----------------------------------------------------------------------------
-- 3.3 NO PUBLIC WRITE/UPDATE/DELETE on display tables
--     (Only authenticated admins via Supabase Dashboard can modify)
--     No policies = denied by default. This is intentional.
-- ----------------------------------------------------------------------------

-- ============================================================================
-- 4. SEED DATA — matches the hardcoded data currently in your frontend
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4.1 TEAMS (8 clubs from teams.html)
-- ----------------------------------------------------------------------------
insert into public.teams (name, short_code, league) values
  ('Manchester City', 'MC', 'Premier League'),
  ('Liverpool', 'LIV', 'Premier League'),
  ('Arsenal', 'ARS', 'Premier League'),
  ('Real Madrid', 'RM', 'La Liga'),
  ('Barcelona', 'BAR', 'La Liga'),
  ('Bayern Munich', 'BAY', 'Bundesliga'),
  ('Juventus', 'JUV', 'Serie A'),
  ('PSG', 'PSG', 'Ligue 1');

-- ----------------------------------------------------------------------------
-- 4.2 PLAYERS (12 players from teams.html)
-- ----------------------------------------------------------------------------
insert into public.players (name, team_id, position, goals, assists, appearances, bio, initials) values
  ('Erling Haaland', (select id from public.teams where short_code = 'MC'), 'FW', 27, 5, 31, 'A prolific Norwegian striker known for his explosive pace, physical dominance, and clinical finishing in the box.', 'EH'),
  ('Mohamed Salah', (select id from public.teams where short_code = 'LIV'), 'FW', 22, 12, 32, 'An Egyptian winger with elite dribbling, vision, and a lethal left foot. A consistent Ballon d''Or contender.', 'MS'),
  ('Bukayo Saka', (select id from public.teams where short_code = 'ARS'), 'FW', 14, 11, 30, 'A versatile English winger who combines technical flair with relentless work rate on both ends of the pitch.', 'BS'),
  ('Jude Bellingham', (select id from public.teams where short_code = 'RM'), 'MF', 18, 8, 29, 'A dynamic English midfielder with box-to-box energy, elite ball-carrying, and a knack for scoring in big moments.', 'JB'),
  ('Lamine Yamal', (select id from public.teams where short_code = 'BAR'), 'FW', 9, 14, 28, 'A teenage prodigy with dazzling close control, creativity, and composure far beyond his years.', 'LY'),
  ('Harry Kane', (select id from public.teams where short_code = 'BAY'), 'FW', 31, 9, 30, 'An elite English striker with world-class finishing, link-up play, and remarkable consistency across leagues.', 'HK'),
  ('Rodri', (select id from public.teams where short_code = 'MC'), 'MF', 7, 6, 30, 'The metronomic Spanish pivot who dictates tempo, breaks up play, and anchors City''s midfield engine.', 'RO'),
  ('Virgil van Dijk', (select id from public.teams where short_code = 'LIV'), 'DF', 3, 2, 29, 'A commanding Dutch centre-back with elite aerial presence, reading of the game, and composure in possession.', 'VV'),
  ('William Saliba', (select id from public.teams where short_code = 'ARS'), 'DF', 2, 1, 30, 'A composed French defender with exceptional recovery speed, positioning, and progressive passing.', 'WS'),
  ('Alisson Becker', (select id from public.teams where short_code = 'LIV'), 'GK', 0, 1, 28, 'A Brazilian shot-stopper renowned for his reflexes, distribution, and ability to produce match-winning saves.', 'AB'),
  ('Kylian Mbappé', (select id from public.teams where short_code = 'RM'), 'FW', 25, 10, 30, 'A French superstar with blistering acceleration, elite finishing, and the ability to change games in an instant.', 'KM'),
  ('Federico Valverde', (select id from public.teams where short_code = 'RM'), 'MF', 6, 7, 31, 'An Uruguayan workhorse with relentless stamina, powerful shooting, and versatility across midfield roles.', 'FV');

-- ----------------------------------------------------------------------------
-- 4.3 FIXTURES (9 matches from fixtures.html + ticker on index.html)
-- ----------------------------------------------------------------------------
insert into public.fixtures (home_team, away_team, home_team_code, away_team_code, home_score, away_score, status, league, kickoff, venue, minute) values
  ('Manchester City', 'Liverpool', 'MC', 'LIV', 2, 1, 'live', 'Premier League', now() - interval '67 minutes', 'Etihad Stadium', 67),
  ('Real Madrid', 'Barcelona', 'RM', 'BAR', 3, 2, 'live', 'La Liga', now() - interval '81 minutes', 'Santiago Bernabéu', 81),
  ('AC Milan', 'Napoli', 'ACM', 'NAP', 0, 0, 'live', 'Serie A', now() - interval '54 minutes', 'San Siro', 54),
  ('PSG', 'Marseille', 'PSG', 'MAR', 0, 0, 'upcoming', 'Ligue 1', now() + interval '2 hours', 'Parc des Princes', 0),
  ('Juventus', 'Inter Milan', 'JUV', 'INT', 0, 0, 'upcoming', 'Serie A', now() + interval '2 hours 15 minutes', 'Allianz Stadium', 0),
  ('Arsenal', 'Chelsea', 'ARS', 'CHE', 0, 0, 'upcoming', 'Premier League', now() + interval '1 day', 'Emirates Stadium', 0),
  ('Bayern Munich', 'Dortmund', 'BAY', 'BVB', 4, 0, 'finished', 'Bundesliga', now() - interval '1 day', 'Allianz Arena', 90),
  ('Ajax', 'Feyenoord', 'AJA', 'FEY', 2, 2, 'finished', 'Eredivisie', now() - interval '1 day', 'Johan Cruyff Arena', 90),
  ('Atletico Madrid', 'Sevilla', 'ATM', 'SEV', 1, 3, 'finished', 'La Liga', now() - interval '1 day', 'Metropolitano', 90);

-- ----------------------------------------------------------------------------
-- 4.4 HEAD_TO_HEAD (matches the H2H drawers on fixtures.html)
-- ----------------------------------------------------------------------------
insert into public.head_to_head (fixture_id, meetings, home_wins, away_wins, draws, home_goals, away_goals) values
  ((select id from public.fixtures where home_team = 'Manchester City' and away_team = 'Liverpool'), 38, 16, 12, 10, 54, 47),
  ((select id from public.fixtures where home_team = 'Real Madrid' and away_team = 'Barcelona'), 52, 22, 18, 12, 78, 71),
  ((select id from public.fixtures where home_team = 'AC Milan' and away_team = 'Napoli'), 44, 19, 14, 11, 61, 52),
  ((select id from public.fixtures where home_team = 'PSG' and away_team = 'Marseille'), 48, 25, 13, 10, 72, 49),
  ((select id from public.fixtures where home_team = 'Juventus' and away_team = 'Inter Milan'), 56, 24, 17, 15, 69, 58),
  ((select id from public.fixtures where home_team = 'Arsenal' and away_team = 'Chelsea'), 50, 20, 18, 12, 63, 59),
  ((select id from public.fixtures where home_team = 'Bayern Munich' and away_team = 'Dortmund'), 60, 32, 12, 16, 98, 61),
  ((select id from public.fixtures where home_team = 'Ajax' and away_team = 'Feyenoord'), 42, 18, 14, 10, 58, 51),
  ((select id from public.fixtures where home_team = 'Atletico Madrid' and away_team = 'Sevilla'), 46, 21, 15, 10, 64, 55);

-- ----------------------------------------------------------------------------
-- 4.5 NEWS (3 articles from index.html)
-- ----------------------------------------------------------------------------
insert into public.news (title, excerpt, category, emoji, read_time, published_at) values
  ('Record-Breaking Deadline Day Deal Shakes the Premier League', 'A stunning £120M move was finalized in the final hour of the window, sending shockwaves through the title race.', 'Transfer', '🏆', 4, now() - interval '2 hours'),
  ('Five-Goal Thriller Ends in Dramatic Late Winner', 'A stoppage-time screamer sealed a memorable comeback as the home side snatched all three points in front of a roaring crowd.', 'Match Report', '⚽', 6, now() - interval '5 hours'),
  ('The Tactical Evolution Reshaping Modern Midfields', 'How inverted full-backs and false nines are redefining the way elite clubs control the tempo of matches.', 'Analysis', '🌟', 8, now() - interval '8 hours');

-- ============================================================================
-- 5. HELPFUL QUERIES FOR YOUR FRONTEND
-- ============================================================================

-- Get all live fixtures (for ticker + fixtures page "Live" filter)
-- select * from public.fixtures where status = 'live' order by minute desc;

-- Get players with their team name (for teams.html player grid)
-- select p.*, t.name as team_name, t.short_code as team_code
-- from public.players p
-- join public.teams t on t.id = p.team_id
-- order by p.goals desc;

-- Get H2H for a specific fixture (for expandable drawer)
-- select * from public.head_to_head where fixture_id = '<fixture-uuid>';

-- Get latest news (for home page news grid)
-- select * from public.news order by published_at desc limit 3;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================