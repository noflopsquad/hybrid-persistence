require './lib/connections'

namespace :db do
  desc "Create tables"
  task :schema do
    execute_sql_script('./db/schema.sql')
  end

  desc "Drop tables"
  task :drop do
    execute_sql_script('./db/drop.sql')
    Connections.mongo[:people].drop
    Connections.mongo[:address_states].drop
    Connections.mongo[:person_states].drop
  end
end

def execute_sql_script script_path
  commands = extract_sql_commands(script_path)
  execute_sql_commands(commands)
end

def extract_sql_commands script_path
  script = File.read(script_path)
  trim(script).split(";")
end

def execute_sql_commands commands
  commands.each do |command|
    Connections.sql.execute(command)
  end
end

def trim str
  str.strip! || str
end
