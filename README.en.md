# dry_beans

🇺🇸 **English** | 🇪🇸 [Español](README.md)

Backend API developed as part of the technical challenge for the Backend Developer position at Drivin. It models a delivery route made up of multiple trips, each with multiple delivery/pickup events.

## Stack and versions

- Ruby: `3.4.10`
- Rails: `~> 8.1.3` (API-only application)
- Database: SQLite (see note in "Decisions and assumptions")

## Getting the project running

### OPTION 1: Development mode

Open a terminal and run the following commands:

```bash
git clone https://github.com/CristobalCabezas/dry_beans.git
cd dry_beans
bundle install
rails db:create db:migrate db:seed
bin/rails server
```

The server will be available at `http://localhost:3000`.

### OPTION 2: With Docker

The project can also be run inside a Docker container; the included `Dockerfile` is geared towards production.

To start it, open a terminal and run the following commands:

```bash
docker build -t dry_beans .
docker run -d -p 3000:80 --name dry_beans dry_beans
```

> **Note:** Since this is only a practical exercise and not meant for a production environment, no `RAILS_MASTER_KEY` is required — if neither `config/master.key` nor `SECRET_KEY_BASE` is provided, `bin/docker-entrypoint` will generate a key and persist it to `storage/secret_key_base` on first boot.

## Domain model

```
Route
  └── has_many :trips
        └── has_many :delivery_events
```

A `Route` groups several `Trip`s (a driver's runs/shifts), and each `Trip` contains multiple `DeliveryEvent`s — the atomic unit of delivering or picking up goods at a stop.

### Why a single `DeliveryEvent` model instead of separate `Delivery` and `Pickup` models

Deliveries and pickups share practically all their attributes (address, contact, status, evidence); the only real difference is the direction the goods move. It was modeled as a single model with an `event_type` field (enum: `delivery` / `pickup`) to avoid duplication with no real benefit.

## `DeliveryEvent` fields and rationale

| Field | Type | Rationale |
|---|---|---|
| `event_type` | enum (`delivery`, `pickup`) | Distinguishes whether it's a delivery or a pickup — the model's core piece of data. |
| `status` | enum (`pending`, `completed`, `failed`) | Indicates whether the event succeeded or failed (e.g. recipient absent) — key for operational traceability. |
| `recipient_name` | string | Records who received the goods — evidence for customer disputes. |
| `address` | string | Address where the event takes place; can differ between stops within the same trip. |
| `scheduled_at` | datetime (nullable) | Planned time for the event — allows measuring SLA compliance. |
| `completed_at` | datetime (nullable) | Actual time it was completed — compared against `scheduled_at` to measure punctuality. |
| `notes` | text (nullable) | Free-form remarks (e.g. "customer did not answer") — captures unstructured exceptions. |

## `Route` fields and rationale

| Field | Type | Rationale |
|---|---|---|
| `code` | string | Unique alphanumeric identifier for the route. |
| `route_date` | date | Estimated start date of the route. |
| `status` | enum (`planned`, `in_progress`, `completed`) | Indicates whether the route is planned (not yet run), in progress, or completed. |

## `Trip` fields and rationale

| Field | Type | Rationale |
|---|---|---|
| `route_id` | integer | Foreign key to the route the trip belongs to. |
| `sequence` | integer | Order in which it will run within the route. |
| `driver_name` | string | Records who is transporting the goods and is responsible for a correct delivery/pickup. |
| `status` | enum (`pending`, `in_progress`, `completed`) | Indicates whether the trip is pending, in progress, or completed. |

## Response format

All endpoints respond with the same envelope:

```json
{ "status": 200, "data": [...], "errors": [] }
```

- `status` can be `200` (OK), `201` (Created), `404` (Not Found), `422` (Unprocessable Entity) or `500` (Internal Server Error), depending on the case.
- `data` is always an array, even in single-resource responses (as can happen with `show`).
- `errors` is also always an array, even when the response is a single resource.

## Endpoints

### Routes

| Method | Path | Description |
|---|---|---|
| `GET` | `/routes` | Lists all routes with their nested trips and events. |
| `GET` | `/routes/:id` | Returns a single route with its nested trips and events. |
| `POST` | `/routes` | Creates a new route. |

**Example `GET /routes/:id` (200):**
```json
{
  "status": 200,
  "data": [
    {
      "id": 1,
      "code": "RUTA-STGO-001",
      "route_date": "2026-09-23",
      "status": "in_progress",
      "trips": [
        {
          "id": 1,
          "sequence": 1,
          "driver_name": "Pedro Álvarez",
          "status": "completed",
          "delivery_events": [
            {
              "id": 1,
              "event_type": "delivery",
              "status": "completed",
              "recipient_name": "María Soto",
              "address": "Av. Providencia 1234, Santiago",
              "notes": "Entregado sin problemas"
            }
          ]
        }
      ]
    }
  ],
  "errors": []
}
```

### Trips

| Method | Path | Description |
|---|---|---|
| `GET` | `/routes/:route_id/trips` | Lists the trips for a route. |
| `POST` | `/routes/:route_id/trips` | Creates a trip associated with an existing route. |

### Delivery events

| Method | Path | Description |
|---|---|---|
| `GET` | `/trips/:trip_id/delivery_events` | Lists the delivery/pickup events for a trip. |
| `POST` | `/trips/:trip_id/delivery_events` | Creates a delivery/pickup event associated with an existing trip. |

**Example request:**
```bash
curl -X POST http://localhost:3000/trips/3/delivery_events \
  -H "Content-Type: application/json" \
  -d '{
    "delivery_event": {
      "event_type": "delivery",
      "status": "pending",
      "recipient_name": "María Soto",
      "address": "Av. Providencia 1234, Santiago",
      "scheduled_at": "2026-09-24T15:30:00",
      "notes": "Dejar en conserjería si no hay nadie"
    }
  }'
```

**Expected response (201):** `{ "status": 201, "data": [<created DeliveryEvent>], "errors": [] }`, including its `trip_id`.
**Errors (422):** `{ "status": 422, "data": [], "errors": ["Recipient name can't be blank", ...] }` if required fields are missing.
**Errors (404):** if the `trip_id` in the URL does not exist (or if the parent resource has no children, see note below).

> **Note:** listing actions (`GET /routes/:route_id/trips`, `GET /trips/:trip_id/delivery_events`) return `404` both when the parent doesn't exist and when it exists but has no associated children (empty collection).

## Admin panel (`public/index.html`)

The project includes a simple HTML panel (no build step, vanilla JS) served as a static file at the root (`http://localhost:3000/`) that consumes these same endpoints to list routes, view their trips and events, and create new trips/events from the browser. It's a support tool for manually testing the API, not part of the challenge's formal scope.

## Postman collection (`postman_dry_beans.json`)

If needed, a `postman_dry_beans.json` file is included in this repository to import a Postman collection with HTTP requests for every endpoint in the project.

## Test data (`db/seeds.rb`)

The seed creates 1 route (`RUTA-STGO-001`) with 5 trips in different states (`completed`, `in_progress`, `pending`) across 3 drivers, plus 2 sample events already loaded on the first trip. Run it with:

```bash
rails db:seed
```

## Tests

```bash
rails test
```

Includes request tests for all three controllers (`routes`, `trips`, `delivery_events`), covering listing, detail, and successful/failed creation. Model tests (`test/models/*_test.rb`) are declared but don't have test cases implemented yet.

## Decisions and assumptions

- **SQLite database:** while relational databases like MySQL, SQL Server or PostgreSQL are more typical in production, SQLite was used for this scoped exercise for configuration simplicity. Migrating to another database is straightforward (change the adapter in `database.yml` and add, e.g., the `mysql2` gem).
- **Partial CRUD for `Route` and `Trip`:** in addition to the endpoints required by the challenge (reading a full route, creating delivery/pickup events), `index`/`show`/`create` were added for `Route` and `Trip` so data could be populated and tested from the HTML panel without depending solely on `seeds.rb`. `update`/`destroy` were not implemented.
- **`event_type` as an enum on a single model** instead of two separate models (`Delivery`/`Pickup`) — see rationale in the domain model section.
- **Authentication:** not implemented, since the challenge doesn't require it and the exercise's focus is data modeling and relationships.

## What I'd add with more time

- `update`/`destroy` for `Route` and `Trip`.
- Token-based authentication for the endpoints.
- A login/users service, where users only have access to routes, trips and events explicitly related to them.
- A robust logging service designed to record and monitor critical business events.
- Pagination and filters (by `status`, `event_type`) on the route query.
- CI (GitHub Actions) running the tests on every push.
- Serialization with a dedicated gem (e.g. `ActiveModel::Serializer` or `Blueprinter`) instead of `as_json(include:)`.
- Complete the model tests (validations and enums).
- Date controls: prevent saving past dates, or events dated earlier than the route's date, etc.
</content>
