InfluxDB::Rails.configure do |config|
  config.influxdb_database = "rails"
  config.influxdb_username = "root"
  config.influxdb_password = "root"
  config.influxdb_hosts    = ["influx"]
  config.influxdb_port     = 8086

  # config.series_name_for_controller_runtimes = "rails.controller"
  # config.series_name_for_view_runtimes       = "rails.view"
  # config.series_name_for_db_runtimes         = "rails.db"
end

# ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
#   InfluxDB::Rails.client.write_point(name, { value: (finish-start), start: start, finish: finish })
# end


# {
#   controller: "PostsController",
#   action: "index",
#   params: {"action" => "index", "controller" => "posts"},
#   headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
#   format: :html,
#   method: "GET",
#   path: "/posts",
#   status: 200,
#   view_runtime: 46.848,
#   db_runtime: 0.157
# }
ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, start, finish, id, data|
  InfluxDB::Rails.client.write_point(
    data[:controller], {
      values: {total:(finish-start), view: data[:view_runtime], db: data[:db_runtime]},
      tags: {action: data[:action], format: data[:format], method: data[:method], status: data[:status]}
    }
  )
end
