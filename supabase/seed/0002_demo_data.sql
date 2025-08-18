-- 0002_demo_data.sql

-- Cliente y sitio demo
insert into client (name) values ('Casasco')
on conflict do nothing;

with cli as (select id from client where name='Casasco')
insert into site (client_id,name,address,contact_name,contact_phone,contact_email)
values ((select id from cli),'Boyacá 123','Boyacá 123, CABA','Contacto Casasco','(011) 1234-5678','contacto@casasco.test')
on conflict do nothing;

-- Equipos demo
with
s as (select id from site where name='Boyacá 123'),
pm as (select code,id from product_model)
insert into equipment (site_id,model_id,serial_number,install_date,feed_water_type,status,notes)
values
((select id from s),(select id from pm where code='IQ7010'),'IQ10-DEMOSN','2024-01-15','tap','active','Equipo demo IQ'),
((select id from s),(select id from pm where code='IX7005'),'IX05-DEMOSN','2024-01-15','tap','active','Equipo demo IX');

-- Configuración: IQ con 3 PODs y tanque; IX sin tanque
with e as (select id, (select id from product_model where code='IQ7010') as iq_id,
                (select id from product_model where code='IX7005') as ix_id
           from equipment)
insert into equipment_config (equipment_id,pod_count,pod_pack_types,has_tank,tank_volume_l,has_asm,has_prepak,extras_json)
select (select id from equipment where serial_number='IQ10-DEMOSN'),3,'["MILLIPAK_A1"]'::jsonb,true,100,true,false,'{}'
union all
select (select id from equipment where serial_number='IX05-DEMOSN'),1,'[]'::jsonb,false,null,false,false,'{}'
on conflict (equipment_id) do nothing;

-- Órdenes de trabajo MP en 7 días
with
st as (select id from service_type where code='MP'),
eq as (select id, serial_number from equipment)
insert into work_order (equipment_id,service_type_id,planned_on,status,notes)
values
((select id from eq where serial_number='IQ10-DEMOSN'),(select id from st), (now() + interval '7 days')::date, 'draft','WO demo IQ MP'),
((select id from eq where serial_number='IX05-DEMOSN'),(select id from st), (now() + interval '7 days')::date, 'draft','WO demo IX MP');
