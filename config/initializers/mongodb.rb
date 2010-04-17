include MongoMapper

db_config = YAML::load(File.read(File.join(Rails.root, "/config/database.yml")))

if db_config[Rails.env] && db_config[Rails.env]['adapter'] == 'mongodb'
  mongo = db_config[Rails.env]
  MongoMapper.connection = Mongo::Connection.new(mongo['host'] || 'localhost',
                                                 mongo['port'] || 27017,
                                                :logger => Rails.logger)
  MongoMapper.database = mongo['database']
  
  # if mongo['username'] && mongo['password']
  #     MongoMapper.database.authenticate(mongo['username'], mongo['password'])
  #   end
end

ActionController::Base.rescue_responses['MongoMapper::DocumentNotFound'] = :not_found

# Used for image uploads
# CarrierWave.configure do |config|
#   mongo = db_config[Rails.env]
#   config.grid_fs_database = mongo['database']
#   config.grid_fs_host = mongo['host'] || 'localhost'
#   config.grid_fs_access_url = "gridfs"
#   config.grid_fs_username = mongo['username']
#   config.grid_fs_password =  mongo['password']
# end

# It's also possible to define indexes in the the model itself; however,
# a few issues are being worked out still. This is a temporary solution.
# Comment.ensure_index([["story_id", 1], ["path", 1], ["points", -1]])
# MongoMapper.ensure_indexes!

# Handle passenger forking.
# if defined?(PhusionPassenger)
#    PhusionPassenger.on_event(:starting_worker_process) do |forked|
#      MongoMapper.database.connect_to_master if forked
#    end
# end