CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_credentials = {
      provider:              "AWS",                                       # required
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],   # required
      aws_secret_access_key: ENV['AWS_SECRET_KEY_ID'],  # required
      region:                "us-east-1"                                  # optional, defaults to "us-east-1"
    }
    config.fog_directory  =  ENV['AWS_BUCKET']                             # required
    #config.fog_host      =  "https://assets.example.com"                 # optional, defaults to nil
    config.fog_public     =  false                                        # optional, defaults to true
    config.fog_attributes =  {"Cache-Control": "max-age=315576000"}       # optional, defaults to {}
  end
end

