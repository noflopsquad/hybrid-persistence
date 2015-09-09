require './lib/connections'

namespace :db do
  desc "Create tables"
  task :schema do
    file = File.read('./db/schema.sql')
    file = file.strip! || file
    commands = file.split(";")
    commands.each do |command|
      Connections.sql.execute(command)
    end
  end

  desc "Drop tables"
  task :drop do
    query = File.read('./db/drop.sql')
    Connections.sql.execute(query)
    Connections.mongo[:people].drop
    Connections.mongo[:address_states].drop
    Connections.mongo[:person_states].drop
  end
end
