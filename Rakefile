require './lib/connections'

task :create_tables do
  Connections.sql.execute("CREATE TABLE IF NOT EXISTS mixed_people(id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT)")
  Connections.sql.execute("CREATE TABLE IF NOT EXISTS mixed_addresses(id INTEGER PRIMARY KEY, street_name TEXT, street_address TEXT, person_id INTEGER)")
end

task :drop_tables do
  Connections.sql.execute("DELETE FROM mixed_people")
  Connections.sql.execute("DELETE FROM mixed_addresses")
  Connections.mongo[:person_states].drop()
  Connections.mongo[:address_states].drop()
end