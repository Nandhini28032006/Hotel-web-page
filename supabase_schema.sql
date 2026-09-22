-- Proper normalized hotel database. Run this once in Supabase SQL Editor.
-- Existing hotel_data is kept for one-time migration of old JSON data.

create extension if not exists pgcrypto;

create table if not exists public.hotel_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  settings jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  address text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  customer_id uuid references public.customers(id) on delete set null,
  invoice_number text not null,
  invoice_date date not null default current_date,
  gst_rate numeric(7,3) not null check (gst_rate >= 0 and gst_rate <= 100),
  subtotal numeric(14,2) not null default 0,
  gst_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0,
  status text not null default 'issued',
  created_at timestamptz not null default now()
);

create table if not exists public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  item_name text not null,
  unit_price numeric(14,2) not null default 0,
  quantity numeric(14,3) not null default 0,
  line_total numeric(14,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  expense_date date not null default current_date,
  category text not null,
  amount numeric(14,2) not null check (amount >= 0),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  payment_date date not null default current_date,
  amount numeric(14,2) not null check (amount >= 0),
  method text not null default 'Cash',
  status text not null default 'paid',
  reference text,
  notes text,
  created_at timestamptz not null default now()
);

create unique index if not exists invoices_user_invoice_number_uq on public.invoices(user_id, invoice_number);
create index if not exists customers_user_idx on public.customers(user_id);
create index if not exists invoices_user_date_idx on public.invoices(user_id, invoice_date);
create index if not exists invoice_items_invoice_idx on public.invoice_items(invoice_id);
create index if not exists expenses_user_date_idx on public.expenses(user_id, expense_date);
create index if not exists payments_user_date_idx on public.payments(user_id, payment_date);

alter table public.hotel_settings enable row level security;
alter table public.customers enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.expenses enable row level security;
alter table public.payments enable row level security;

drop policy if exists "Users manage own hotel settings" on public.hotel_settings;
create policy "Users manage own hotel settings" on public.hotel_settings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own customers" on public.customers;
create policy "Users manage own customers" on public.customers for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own invoices" on public.invoices;
create policy "Users manage own invoices" on public.invoices for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own invoice items" on public.invoice_items;
create policy "Users manage own invoice items" on public.invoice_items for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own expenses" on public.expenses;
create policy "Users manage own expenses" on public.expenses for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own payments" on public.payments;
create policy "Users manage own payments" on public.payments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Keep the old table for migration/backup. The new app no longer uses it for normal storage.
