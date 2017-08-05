USERS_WHITELIST = YAML.load_file("#{Rails.root}/config/users_whitelist.yml")[Rails.env]
