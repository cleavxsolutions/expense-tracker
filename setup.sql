-- ============================================================
-- Ledger — Expense Tracker: Database Setup
-- Paste this whole file into Supabase → SQL Editor → New query
-- and click "Run". It creates two tables and locks them down so
-- each signed-in user can only ever see and edit their own rows.
-- ============================================================

-- Expenses / income transactions
create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  amount numeric(12,2) not null check (amount > 0),
  category text,
  type text not null check (type in ('income','expense')),
  date date not null,
  created_at timestamptz not null default now()
);

-- Monthly budget limits per category
create table if not exists budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  monthly_limit numeric(12,2) not null check (monthly_limit > 0),
  created_at timestamptz not null default now(),
  unique (user_id, category)
);

-- Helpful indexes
create index if not exists expenses_user_id_idx on expenses(user_id);
create index if not exists budgets_user_id_idx on budgets(user_id);

-- Lock both tables down: row level security ON
alter table expenses enable row level security;
alter table budgets  enable row level security;

-- A user may only see, add, change, or delete THEIR OWN rows
create policy "select own expenses" on expenses for select using (auth.uid() = user_id);
create policy "insert own expenses" on expenses for insert with check (auth.uid() = user_id);
create policy "update own expenses" on expenses for update using (auth.uid() = user_id);
create policy "delete own expenses" on expenses for delete using (auth.uid() = user_id);

create policy "select own budgets" on budgets for select using (auth.uid() = user_id);
create policy "insert own budgets" on budgets for insert with check (auth.uid() = user_id);
create policy "update own budgets" on budgets for update using (auth.uid() = user_id);
create policy "delete own budgets" on budgets for delete using (auth.uid() = user_id);
