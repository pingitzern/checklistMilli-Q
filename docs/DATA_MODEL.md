# Data Model (v1)

## Catálogo
- product_family {id, code, name, generation}
- product_model {id, family_id, code, name, outputs_json, successor_of?, notes}
- consumable {id, code, name, category, platform, replace_every_months?, per_pod, pair_group?, rfid_required, metadata_json}
- accessory {id, code, name, metadata_json}
- model_consumable {model_id, consumable_id, purpose, base_qty, qty_formula_json?, cond_formula_json?, enforcement}
- service_type {id, code, name}
- service_template {id, model_id, service_type_id}
- service_template_item {id, template_id, consumable_id, base_qty, qty_formula_json?, cond_formula_json?, notes}

## Instalado
- client {id, name, tax_id?, notes}
- site {id, client_id, name, address, contact_name, contact_phone, contact_email}
- equipment {id, site_id, model_id, serial_number, install_date, feed_water_type, status, notes}
- equipment_config {equipment_id, pod_count, pod_pack_types[], has_tank, tank_volume_l?, has_asm, has_prepak, prepak_type?, extras_json}
- equipment_consumable_state {equipment_id, consumable_id, last_replaced_at, usage_hours?, meter_value?}

## Operación
- work_order {id, equipment_id, service_type_id, planned_on, status, notes}
- previsit_checklist {id, work_order_id, generated_at, payload_json}
- previsit_answer {id, checklist_id, received_at, payload_json}
- service_event {id, work_order_id, performed_at, outcome, notes}
- service_event_item {id, service_event_id, consumable_id, qty, notes}
- equipment_change_log {id, equipment_id, changed_at, change_json}
