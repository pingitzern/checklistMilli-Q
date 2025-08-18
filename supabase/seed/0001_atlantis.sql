-- 0001_atlantis.sql

-- Familia
insert into product_family (code,name,generation) values
('ATLANTIS','Milli-Q Atlantis','ATLANTIS')
on conflict (code) do nothing;

-- Modelos mínimos
with fam as (select id from product_family where code='ATLANTIS')
insert into product_model (family_id,code,name,outputs_json) values
((select id from fam),'IQ7003','IQ 7003','{"type1":true,"type2":true,"type3":false}'),
((select id from fam),'IQ7005','IQ 7005','{"type1":true,"type2":true,"type3":false}'),
((select id from fam),'IQ7010','IQ 7010','{"type1":true,"type2":true,"type3":false}'),
((select id from fam),'IQ7015','IQ 7015','{"type1":true,"type2":true,"type3":false}'),
((select id from fam),'IX7003','IX 7003','{"type1":false,"type2":true,"type3":false}'),
((select id from fam),'IX7005','IX 7005','{"type1":false,"type2":true,"type3":false}'),
((select id from fam),'IX7010','IX 7010','{"type1":false,"type2":true,"type3":false}'),
((select id from fam),'IX7015','IX 7015','{"type1":false,"type2":true,"type3":false}'),
((select id from fam),'EQ7008','EQ 7008','{"type1":true,"type2":false,"type3":true}'),
((select id from fam),'EQ7016','EQ 7016','{"type1":true,"type2":false,"type3":true}')
on conflict (code) do nothing;

-- Consumibles (ATLANTIS)
-- TODO: Reemplazar códigos por los exactos del documento cuando se disponga.
insert into consumable (code,name,category,platform,replace_every_months,per_pod,rfid_required,metadata_json,pair_group) values
('IPAKGARD1','IPAK Gard 1','pretratamiento','ATLANTIS',12,false,true,'{}',null),
('IPAKGARD2','IPAK Gard 2','pretratamiento','ATLANTIS',12,false,true,'{}',null),
('IPAKGARDH1','IPAK Gard H1','pretratamiento','ATLANTIS',12,false,true,'{}',null),
('IPAKGARDH2','IPAK Gard H2','pretratamiento','ATLANTIS',12,false,true,'{}',null),

('IPAKMETA','IPAK Meta','pulido','ATLANTIS',12,false,true,'{}','IPAK_PAIR'),
('IPAKQUANTA','IPAK Quanta','pulido','ATLANTIS',12,false,true,'{}','IPAK_PAIR'),

('MILLIPAK_A1','Millipak A1 (0.22 µm)','pod_pak','ATLANTIS',12,true,true,'{}',null),
('BIOPAK_A1','BioPak A1 (UF)','pod_pak','ATLANTIS',12,true,true,'{}',null),
('LCPAK_A1','LC-Pak A1','pod_pak','ATLANTIS',12,true,true,'{}',null),
('VOCPAK_A1','VOC-Pak A1','pod_pak','ATLANTIS',12,true,true,'{}',null),
('EDSPAK_A1','EDS-Pak A1','pod_pak','ATLANTIS',12,true,true,'{}',null),

('TANKVH1A1','Filtro venteo tanque HF','vent_filter','ATLANTIS',12,false,false,'{}',null),

('UV_ECH2O_172','UV ech2o 172 nm (fotooxidación)','uv','ATLANTIS',24,false,false,'{}',null),
('LED_UVC_265','LED UVC 265 nm (ASM tanque)','uv','ATLANTIS',24,false,false,'{}',null),
('A10_ECH2O','A10 UV ech2o (IQ)','uv','ATLANTIS',24,false,false,'{}',null),

('SANIKIT_RO','Kit sanitización RO/loop','sanitizacion','ATLANTIS',null,false,false,'{}',null)
on conflict (code) do nothing;

-- Tipos de servicio
insert into service_type (code,name) values
('MP','Mantenimiento Preventivo'),
('CAL','Calibración'),
('OQ','Calificación Operacional'),
('VAL','Validación'),
('MC','Mantenimiento Correctivo')
on conflict (code) do nothing;

-- Plantillas MP por modelo
-- Helper: devuelve id de modelo y consumible por code
with
m as (select code,id from product_model),
c as (select code,id from consumable),
st as (
  insert into service_template (model_id,service_type_id)
  select m.id, (select id from service_type where code='MP')
  from product_model m
  where m.code in ('IQ7003','IQ7005','IQ7010','IQ7015','IX7003','IX7005','IX7010','IX7015','EQ7008','EQ7016')
  on conflict (model_id,service_type_id) do nothing
  returning id, model_id
)
-- Items por plantilla
insert into service_template_item (template_id, consumable_id, base_qty, qty_formula_json, cond_formula_json, notes)
select st.id, citem.id,
  -- base_qty
  case
    when citem.code in ('IPAKMETA','IPAKQUANTA') then 1
    when citem.code in ('MILLIPAK_A1','BIOPAK_A1','LCPAK_A1','VOCPAK_A1','EDSPAK_A1') then 1
    when citem.code = 'TANKVH1A1' then 1
    else 1
  end as base_qty,
  -- qty_formula_json
  case
    when citem.code in ('MILLIPAK_A1','BIOPAK_A1','LCPAK_A1','VOCPAK_A1','EDSPAK_A1')
      then '{"type":"per_pod","field":"pod_count","min":1}'::jsonb
    when citem.code = 'TANKVH1A1'
      then '{"type":"per_tank","field":"has_tank","default":1}'::jsonb
    else null
  end as qty_formula_json,
  -- cond_formula_json (12m general; 24m para UV/LED/A10)
  case
    when citem.code in ('UV_ECH2O_172','LED_UVC_265','A10_ECH2O')
      then '{"type":"months_since","field":"last_replaced_at","gte":24}'::jsonb
    when citem.code in ('SANIKIT_RO')
      then null
    else '{"type":"months_since","field":"last_replaced_at","gte":12}'::jsonb
  end as cond_formula_json,
  -- notes
  case
    when citem.code in ('IPAKMETA','IPAKQUANTA') then 'Cambiar siempre en pareja (pair_group=IPAK_PAIR).'
    when citem.code in ('MILLIPAK_A1','BIOPAK_A1','LCPAK_A1','VOCPAK_A1','EDSPAK_A1') then 'Cantidad = # de PODs.'
    when citem.code = 'TANKVH1A1' then 'Un filtro por tanque.'
    when citem.code in ('UV_ECH2O_172','LED_UVC_265','A10_ECH2O') then 'Reemplazo por horas/estado; si no hay horas, fallback 24m.'
    else null
  end
from st
join m on m.id = st.model_id
join c citem on true
where
  -- IQ: incluir IPAK Gard, Meta+Quanta, POD-Paks, Vent, UV/LED/A10
  (m.code in ('IQ7003','IQ7005','IQ7010','IQ7015')
   and citem.code in ('IPAKGARD1','IPAKGARD2','IPAKGARDH1','IPAKGARDH2','IPAKMETA','IPAKQUANTA','MILLIPAK_A1','BIOPAK_A1','LCPAK_A1','VOCPAK_A1','EDSPAK_A1','TANKVH1A1','UV_ECH2O_172','LED_UVC_265','A10_ECH2O'))
  or
  -- IX: IPAK Gard, Vent, UV (sin Meta/Quanta; sin POD-Paks de Tipo 1)
  (m.code in ('IX7003','IX7005','IX7010','IX7015')
   and citem.code in ('IPAKGARD1','IPAKGARD2','IPAKGARDH1','IPAKGARDH2','TANKVH1A1','UV_ECH2O_172'))
  or
  -- EQ: IPAK Gard, Meta+Quanta (si produce Tipo 1), POD-Paks, Vent, UV/LED; sanitización opcional
  (m.code in ('EQ7008','EQ7016')
   and citem.code in ('IPAKGARD1','IPAKGARD2','IPAKGARDH1','IPAKGARDH2','IPAKMETA','IPAKQUANTA','MILLIPAK_A1','BIOPAK_A1','LCPAK_A1','VOCPAK_A1','EDSPAK_A1','TANKVH1A1','UV_ECH2O_172','LED_UVC_265','SANIKIT_RO'));
