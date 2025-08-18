# checklistMilli-Q

A minimal planning and checklist management prototype for ATLANTIS service visits. The project organizes catalogs of equipment and consumables, tracks maintenance work orders, and generates pre-visit checklists for customers.

## Development prerequisites

- Node.js >= 20
- [Supabase CLI](https://supabase.com/docs/guides/cli) authenticated to your project

Install dependencies:

```sh
npm install
```

## Directory structure

- `docs/` – design notes and data model documentation
- `scripts/` – helper scripts
- `supabase/` – database schema, migrations, and seeds
- `web/` – minimal UI for CRUD operations and checklist generation

## Running database migrations and seeds

1. Authenticate with Supabase and link the project: `supabase login` and `supabase link --project-ref <ref>`
2. Apply migrations:

```sh
npm run db:push
```

3. Seed the database:

```sh
npm run db:seed
```

These npm scripts wrap the Supabase CLI and use the configuration in the `supabase/` directory.

## License

This project is licensed under the [MIT License](LICENSE).
