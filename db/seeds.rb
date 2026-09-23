DeliveryEvent.destroy_all
Trip.destroy_all
Route.destroy_all


# Create a route

route = Route.create!(
    code: "RUTA-STGO-001",
    route_date: Date.today,
    status: :in_progress
)

# Create trips for the route

trip_1 = route.trips.create!(
    sequence: 1,
    driver_name: "Pedro Álvarez",
    status: :completed
)

trip_2 = route.trips.create!(
    sequence: 2,
    driver_name: "Pedro Álvarez",
    status: :in_progress
)

trip_3 = route.trips.create!(
    sequence: 3,
    driver_name: "Camila Rojas",
    status: :pending
)

trip_4 = route.trips.create!(
    sequence: 4,
    driver_name: "Camila Rojas",
    status: :pending
)

trip_5 = route.trips.create!(
    sequence: 5,
    driver_name: "Ignacio Fuentes",
    status: :pending
)

# Create delivery events for trip 1

trip_1.delivery_events.create!(
    event_type: :delivery,
    status: :completed,
    recipient_name: "María Soto",
    address: "Av. Providencia 1234, Santiago",
    scheduled_at: 2.hours.ago,
    completed_at: 1.hour.ago,
    notes: "Entregado sin problemas"
)

trip_1.delivery_events.create!(
    event_type: :pickup,
    status: :failed,
    recipient_name: "Comercial Andes SpA",
    address: "San Pablo 4567, Santiago",
    scheduled_at: 1.hour.ago,
    completed_at: nil,
    notes: "Local cerrado, se reagenda"
)

# Print summary of created records

puts "Seed completed:"
puts "  Route #{route.id}, #{route.code}, #{route.route_date}, #{route.status}"
puts "  Trips: #{route.trips.pluck(:id, :sequence, :driver_name, :status).inspect}"
puts "  Delivery Events for Trip 1: #{trip_1.delivery_events.pluck(:id, :event_type, :status, :recipient_name, :address, :scheduled_at, :completed_at).inspect}"