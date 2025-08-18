-- 0002_policies.sql

-- Catálogo: permitir SELECT a usuarios autenticados.
do $$ begin
  perform 1;
exception when others then
  -- noop
end $$;

create policy catalog_select_all on product_family for select to authenticated using (true);
create policy catalog_select_all2 on product_model for select to authenticated using (true);
create policy catalog_select_all3 on consumable for select to authenticated using (true);
create policy catalog_select_all4 on accessory for select to authenticated using (true);
create policy catalog_select_all5 on model_consumable for select to authenticated using (true);
create policy catalog_select_all6 on service_type for select to authenticated using (true);
create policy catalog_select_all7 on service_template for select to authenticated using (true);
create policy catalog_select_all8 on service_template_item for select to authenticated using (true);

-- Operación e instalados: permitir SELECT a autenticados (mínimo para desarrollo).
create policy op_select_clients on client for select to authenticated using (true);
create policy op_select_sites on site for select to authenticated using (true);
create policy op_select_equipment on equipment for select to authenticated using (true);
create policy op_select_equipment_config on equipment_config for select to authenticated using (true);
create policy op_select_equipment_state on equipment_consumable_state for select to authenticated using (true);

create policy op_select_work_order on work_order for select to authenticated using (true);
create policy op_select_previsit_checklist on previsit_checklist for select to authenticated using (true);
create policy op_select_previsit_answer on previsit_answer for select to authenticated using (true);
create policy op_select_service_event on service_event for select to authenticated using (true);
create policy op_select_service_event_item on service_event_item for select to authenticated using (true);
create policy op_select_equipment_change_log on equipment_change_log for select to authenticated using (true);

-- Para desarrollo: permitir INSERT/UPDATE/DELETE a authenticated (temporal).
create policy dev_write_client on client for all to authenticated using (true) with check (true);
create policy dev_write_site on site for all to authenticated using (true) with check (true);
create policy dev_write_equipment on equipment for all to authenticated using (true) with check (true);
create policy dev_write_equipment_config on equipment_config for all to authenticated using (true) with check (true);
create policy dev_write_equipment_state on equipment_consumable_state for all to authenticated using (true) with check (true);

create policy dev_write_work_order on work_order for all to authenticated using (true) with check (true);
create policy dev_write_previsit_checklist on previsit_checklist for all to authenticated using (true) with check (true);
create policy dev_write_previsit_answer on previsit_answer for all to authenticated using (true) with check (true);
create policy dev_write_service_event on service_event for all to authenticated using (true) with check (true);
create policy dev_write_service_event_item on service_event_item for all to authenticated using (true) with check (true);
create policy dev_write_equipment_change_log on equipment_change_log for all to authenticated using (true) with check (true);

-- NOTA: Estas policies son deliberadamente permisivas para DEV.
-- En PROD reemplazaremos por policies con roles (service_coordinator, field_tech, client_user) y filtros por client_id.
