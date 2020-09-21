Rails.application.configure do |config|
  config.middleware.use Rack::Attack unless (Rails.env.test? || Rails.env.development?)
end

# ex: to restrict UI access to VPN
if ENV['UI_WHITELIST_IPS'].present?
  Rack::Attack.blocklist('block all but whitelisted ips') do |req|
    !(req.path =~ /\A\/api/) && !ENV['UI_WHITELIST_IPS'].split(",").include?(req.ip)
  end
end

# ex: to restrict API access to our server
if ENV['API_WHITELIST_IPS'].present?
  Rack::Attack.blocklist('block all but whitelisted ips') do |req|
    (req.path =~ /\A\/api/) && !ENV['API_WHITELIST_IPS'].split(",").include?(req.ip)
  end
end

if ENV['BLOCKED_IPS'].present?
  ENV['BLOCKED_IPS'].split(",").each do |ip|
    Rack::Attack.blocklist_ip(ip)
  end
end

Rack::Attack.blocklisted_response = lambda do |env|
  [ 404, {}, [File.open(Rails.root.join("public/404.html")).read]]
end
