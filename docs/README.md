# MPV — Planificación de Servicios (ATLANTIS v1)

Objetivo: montar catálogo ATLANTIS, equipos instalados, WO (MP) y checklist previo a la visita.
Ámbito inicial:
- Catálogo ATLANTIS (familia, modelos, consumibles, plantillas MP).
- CRUD básico de clientes, sitios, equipos.
- Crear WO de MP y generar checklist con reglas mínimas (per_pod, per_tank, replace_every_months).
- Pre-visita (respuesta del cliente) y cierre (insumos usados).

Parámetros iniciales acordados:
- Frecuencia por defecto: 12 meses para consumibles generales.
- Lámparas/UV/LED/A10: 24 meses (fallback si no hay horas de uso).
- Variabilidad: los filtros finales dependen de # de PODs y tipo de POD-Pak por equipo.

Escalable a: CAL/OQ/VAL/MC, reglas avanzadas, telemetría, PDF server-side, multi-tenant.
