Gem::Specification.new do |s|
  s.name        = 'yesmail2'
  s.version     = '0.0.1'
  s.date        = '2013-09-12'
  s.summary     = "Yesmail v2"
  s.description = "Ruby wrapper for v2 of the yesmail API"
  s.authors     = ["ApartmentList"]
  s.email       = 'alan@autolist.com'
  s.files       = Dir["lib/**/*.rb"]
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/apartmentlist/yesmail2'
 
  gem.add_dependency 'rest-client'
  gem.add_dependency 'json'
  gem.add_dependency 'logger'
  gem.add_dependency 'hashie'
  gem.add_development_dependency 'pp'
  gem.add_development_dependency 'pry'
end
