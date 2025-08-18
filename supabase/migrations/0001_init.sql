-- 0001_init.sql
create extension if not exists pgcrypto;

-- =====================
-- Catálogo
-- =====================
create table if not exists product_family (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  generation text
);

create table if not exists product_model (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references product_family(id) on delete restrict,
  code text unique not null,
  name text not null,
  outputs_json jsonb default '{}',
  successor_of uuid null references product_model(id),
  notes text
);

create table if not exists consumable (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  category text not null,          -- pretratamiento | pulido | pod_pak | vent_filter | uv | sanitizacion | otro
  platform text,                   -- ATLANTIS | INTEGRAL | ...
  replace_every_months int null,   -- 12 por defecto, 24 para UV/LED/A10; null si depende de horas
  per_pod boolean default false,
  pair_group text null,            -- ej 'IPAK_PAIR' para Meta+Quanta
  rfid_required boolean default false,
  metadata_json jsonb default '{}'
);

create table if not exists accessory (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  metadata_json jsonb default '{}'
);

create table if not exists model_consumable (
  model_id uuid not null references product_model(id) on delete cascade,
  consumable_id uuid not null references consumable(id) on delete restrict,
  purpose text not null,                 -- PRETRAT | TIPO1 | TIPO2 | POD_PACK | TANQUE | UV | SANIT
  base_qty numeric default 1,
  qty_formula_json jsonb null,           -- {"type":"per_pod","field":"pod_count","min":1} | {"type":"per_tank","field":"has_tank"} | {"type":"fixed","value":1}
  cond_formula_json jsonb null,          -- {"type":"months_since","field":"last_replaced_at","gte":12}
  enforcement text null,                 -- STRICT | ALLOWED | BLOCKED
  primary key (model_id, consumable_id, purpose)
);

create table if not exists service_type (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,             -- MP | CAL | OQ | VAL | MC
  name text not null
);

create table if not exists service_template (
  id uuid primary key default gen_random_uuid(),
  model_id uuid not null references product_model(id) on delete cascade,
  service_type_id uuid not null references service_type(id) on delete cascade,
  unique (model_id, service_type_id)
);

create table if not exists service_template_item (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references service_template(id) on delete cascade,
  consumable_id uuid not null references consumable(id) on delete restrict,
  base_qty numeric default 1,
  qty_formula_json jsonb null,
  cond_formula_json jsonb null,
  notes text null
);

-- =====================
-- Instalado en cliente
-- =====================
create table if not exists client (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tax_id text null,
  notes text
);

create table if not exists site (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references client(id) on delete cascade,
  name text not null,
  address text,
  contact_name text,
  contact_phone text,
  contact_email text
);

create table if not exists equipment (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references site(id) on delete cascade,
  model_id uuid not null references product_model(id) on delete restrict,
  serial_number text,
  install_date date null,
  feed_water_type text,                   -- tap | type2 | type3
  status text default 'active',
  notes text
);

create table if not exists equipment_config (
  equipment_id uuid primary key references equipment(id) on delete cascade,
  pod_count int default 1,
  pod_pack_types jsonb default '[]',      -- ["MILLIPAK_A1","BIOPAK_A1",...]
  has_tank boolean default false,
  tank_volume_l int null,                 -- 25/50/100
  has_asm boolean default false,
  has_prepak boolean default false,
  prepak_type text null,
  extras_json jsonb default '{}'
);

create table if not exists equipment_consumable_state (
  equipment_id uuid not null references equipment(id) on delete cascade,
  consumable_id uuid not null references consumable(id) on delete restrict,
  last_replaced_at date null,
  usage_hours numeric null,
  meter_value numeric null,
  primary key (equipment_id, consumable_id)
);

-- =====================
-- Operación
-- =====================
create table if not exists work_order (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null references equipment(id) on delete cascade,
  service_type_id uuid not null references service_type(id) on delete restrict,
  planned_on date null,
  status text default 'draft',            -- draft | awaiting_client | ready | done | blocked
  notes text
);

create table if not exists previsit_checklist (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid not null references work_order(id) on delete cascade,
  generated_at timestamptz default now(),
  payload_json jsonb not null
);

create table if not exists previsit_answer (
  id uuid primary key default gen_random_uuid(),
  checklist_id uuid not null references previsit_checklist(id) on delete cascade,
  received_at timestamptz default now(),
  payload_json jsonb not null
);

create table if not exists service_event (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid not null references work_order(id) on delete cascade,
  performed_at timestamptz default now(),
  outcome text,                           -- completed | blocked_missing_consumable | blocked_equipment_fault | ...
  notes text
);

create table if not exists service_event_item (
  id uuid primary key default gen_random_uuid(),
  service_event_id uuid not null references service_event(id) on delete cascade,
  consumable_id uuid not null references consumable(id) on delete restrict,
  qty numeric,
  notes text
);

create table if not exists equipment_change_log (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null references equipment(id) on delete cascade,
  changed_at timestamptz default now(),
  change_json jsonb not null
);

-- =====================
-- RLS ON (policies en 0002)
-- =====================
alter table product_family enable row level security;
alter table product_model enable row level security;
alter table consumable enable row level security;
alter table accessory enable row level security;
alter table model_consumable enable row level security;
alter table service_type enable row level security;
alter table service_template enable row level security;
alter table service_template_item enable row level security;

alter table client enable row level security;
alter table site enable row level security;
alter table equipment enable row level security;
alter table equipment_config enable row level security;
alter table equipment_consumable_state enable row level security;

alter table work_order enable row level security;
alter table previsit_checklist enable row level security;
alter table previsit_answer enable row level security;
alter table service_event enable row level security;
alter table service_event_item enable row level security;
alter table equipment_change_log enable row level security;
