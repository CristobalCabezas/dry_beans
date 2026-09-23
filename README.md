# dry_beans

API backend desarrollada como parte del desafío técnico para la posición de Backend Developer en Drivin. Modela una ruta de reparto compuesta por múltiples viajes, cada uno con múltiples eventos de entrega y/o retiro.

## Stack y versiones

- Ruby: `3.4.10`
- Rails: `~> 8.1.3` (API-only application)
- Base de datos: SQLite (ver nota en "Decisiones y supuestos")

## Cómo levantar el proyecto

### OPCION 1: Modo desarrollo

Abrir una terminal o consola y ejecutar los siguientes comandos:

```bash
git clone https://github.com/CristobalCabezas/dry_beans.git
cd dry_beans
bundle install
rails db:create db:migrate db:seed
bin/rails server
```

El servidor queda disponible en `http://localhost:3000`.

### OPCION 2: Con Docker

Se ha incluido la opción de abrir el proyecto dentro de un contenedor Docker, cuyo `Dockerfile` está orientado a producción.

Para iniciarlo, abrir una terminal o consola y ejecutar los siguietes comandos:

```bash
docker build -t dry_beans .
docker run -d -p 3000:80 --name dry_beans dry_beans
```

> **Nota:** Dado que solo se trata de un ejercicio práctico no orientado a un ambiente de producción, se deja constancia que no se requiere de una `RAILS_MASTER_KEY`, por lo que si no se provee ni `config/master.key` ni `SECRET_KEY_BASE`, `bin/docker-entrypoint` generará una clave y la persistirá en `storage/secret_key_base` en el primer arranque.

## Modelo de dominio

```
Route (ruta)
  └── has_many :trips (viajes)
        └── has_many :delivery_events (entregas/retiros)
```

Una `Route` agrupa varios `Trip` (viajes/turnos de un conductor), y cada `Trip` contiene múltiples `DeliveryEvent` — el evento atómico de entrega o retiro de mercadería en una parada.

### Por qué un solo modelo `DeliveryEvent` en vez de `Delivery` y `Pickup` separados

Entrega y retiro comparten prácticamente todos los atributos (dirección, contacto, estado, evidencia); la única diferencia real es la dirección del movimiento de la mercadería. Se modeló como un único modelo con un campo `event_type` (enum: `delivery` / `pickup`) para evitar duplicación sin beneficio real.

## Campos de `DeliveryEvent` y justificación

| Campo | Tipo | Justificación |
|---|---|---|
| `event_type` | enum (`delivery`, `pickup`) | Distingue si es una entrega o un retiro — dato central del modelo. |
| `status` | enum (`pending`, `completed`, `failed`) | Indica si el evento se concretó o falló (ej. destinatario ausente), clave para trazabilidad operativa. |
| `recipient_name` | string | Registra quién recibió la mercadería — evidencia ante disputas con clientes. |
| `address` | string | Dirección donde ocurre el evento; puede diferir entre paradas de un mismo viaje. |
| `scheduled_at` | datetime (nullable) | Hora planificada del evento — permite medir cumplimiento de SLA. |
| `completed_at` | datetime (nullable) | Hora real en que se concretó — se compara contra `scheduled_at` para medir puntualidad. |
| `notes` | text (nullable) | Observaciones libres (ej. "cliente no atendió") — captura excepciones no estructuradas. |

## Campos de `Route` y justificación

| Campo | Tipo | Justificación |
|---|---|---|
| `code` | string | Identificador único alfanumérico de la ruta. |
| `route_date` | date | Fecha estimada de inicio de la ruta. |
| `status` | enum (`planned`, `in_progress`, `completed`) | Indica si la ruta está planificada (por ejecutar), en progreso (en ejecución) o completada (ejecutada). |


## Campos de `Trip` y justificación

| Campo | Tipo | Justificación |
|---|---|---|
| `route_id` | integer | Foreing key de la ruta asociada al viaje |
| `sequence` | integer | Número de orden en que se ejecutará dentro de la ruta |
| `driver_name` | string | Registra quien transporta y se hace respnsable de la correcta entrega o retiro. |
| `status` | enum (`pending`, `in_progress`, `completed`) | Indica si el viaje se encuentra pendiente, en curso o completado. |

## Formato de respuesta

Todos los endpoints responden con el mismo sobre (envelope):

```json
{ "status": 200, "data": [...], "errors": [] }
```

- `status` puede ser `200` (OK), `201` (Created), `404` (Not Found), `422` (Unprocessable Entity) o `500` (Internal Server Error), dependiendo el caso.
- `data` es siempre un array, incluso en respuestas de un solo recurso (como puede ocurrir con `show`).
- `errors` también es siempre un array, aunque su respuesta sea un solo recurso.

## Endpoints

### Routes

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/routes` | Lista todas las rutas con sus viajes y eventos anidados. |
| `GET` | `/routes/:id` | Retorna una ruta puntual con sus viajes y eventos anidados. |
| `POST` | `/routes` | Crea una nueva ruta. |

**Ejemplo `GET /routes/:id` (200):**
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

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/routes/:route_id/trips` | Lista los viajes de una ruta. |
| `POST` | `/routes/:route_id/trips` | Crea un viaje asociado a una ruta existente. |

### Delivery events

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/trips/:trip_id/delivery_events` | Lista los eventos de entrega/retiro de un viaje. |
| `POST` | `/trips/:trip_id/delivery_events` | Crea un evento de entrega/retiro asociado a un viaje existente. |

**Request de ejemplo:**
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

**Respuesta esperada (201):** `{ "status": 201, "data": [<DeliveryEvent creado>], "errors": [] }`, incluyendo su `trip_id`.
**Errores (422):** `{ "status": 422, "data": [], "errors": ["Recipient name can't be blank", ...] }` si faltan campos obligatorios.
**Errores (404):** si el `trip_id` de la URL no existe (o si el recurso padre no tiene hijos, ver nota abajo).

> **Nota:** las acciones de listado (`GET /routes/:route_id/trips`, `GET /trips/:trip_id/delivery_events`) devuelven `404` tanto si el padre no existe como si existe pero no tiene hijos asociados (colección vacía).

## Panel de administración (`public/index.html`)

El proyecto incluye un panel HTML simple (sin build step, JS vanilla) servido como archivo estático en la raíz (`http://localhost:3000/`) que consume estos mismos endpoints para listar rutas, ver sus viajes y eventos, y crear nuevos viajes/eventos desde el navegador. Es una herramienta de apoyo para probar la API manualmente, no parte del alcance formal del desafío.

## Collection para Postman (`postman_dry_beans.json`)

En caso que se requiera, se ha dispuesto en este repositorio un archivo json llamado `postman_dry_beans.json` para importar en Postman una colección de peticiones HTTP de todos los endpoints del proyecto.

## Datos de prueba (`db/seeds.rb`)

El seed crea 1 ruta (`RUTA-STGO-001`) con 5 viajes en distintos estados (`completed`, `in_progress`, `pending`) y 3 conductores distintos, más 2 eventos de ejemplo ya cargados en el primer viaje. Correr con:

```bash
rails db:seed
```

## Tests

```bash
rails test
```

Incluye tests de request para los tres controladores (`routes`, `trips`, `delivery_events`), cubriendo listado, detalle y creación exitosa/fallida. Los tests de modelo (`test/models/*_test.rb`) están declarados pero aún sin casos implementados.

## Decisiones y supuestos

- **Base de datos SQLite:** Si bien lo usual es que en producción se utilicen bases de datos relacionales como MySQL, SQL Server o PostgreSQL, para este ejercicio acotado se usó SQLite por simplicidad de configuración. La migración a cualquier otra base de datos es directa (cambio de adapter en `database.yml` y gema `mysql2`, por ejemplo).
- **CRUD parcial de `Route` y `Trip`:** además de los endpoints pedidos por el enunciado (lectura de ruta completa, creación de eventos de entrega/retiro), se agregaron `index`/`show`/`create` para `Route` y `Trip` para poder poblar y probar datos desde el panel HTML sin depender únicamente de `seeds.rb`. No se implementaron `update`/`destroy`.
- **`event_type` como enum en un solo modelo** en vez de dos modelos separados (`Delivery`/`Pickup`) — ver justificación en la sección de modelo de dominio.
- **Autenticación:** no se implementó, dado que el enunciado no la exige y el foco del ejercicio es el modelado de datos y las relaciones.

## Qué agregaría con más tiempo

- `update`/`destroy` para `Route` y `Trip`.
- Autenticación por token para los endpoints.
- Servicio de login y usuarios, los cuales solo tienen acceso a las rutas, viajes y eventos explícitamente relacionados.
- Servicio de logs robusto y pensado para registrar y controlar los aspectos críticos del negocio.
- Paginación y filtros (por `status`, `event_type`) en la consulta de ruta.
- CI (GitHub Actions) corriendo los tests en cada push.
- Serialización con una gema dedicada (ej. `ActiveModel::Serializer` o `Blueprinter`) en vez de `as_json(include:)`.
- Completar los tests de modelo (validaciones y enums).
- Control de fechas: Impedir guardar fechas pasadas, o que los eventos tengan fecha a anterior a la de la ruta, etc.
