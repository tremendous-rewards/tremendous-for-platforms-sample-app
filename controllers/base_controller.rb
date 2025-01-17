class BaseController < Sinatra::Base
  configure do
    set :views, File.expand_path('../../views', __FILE__)
    set :method_override, true

    set :sessions, {
      same_site: :lax, # needed due to cross-site redirects
      secret: ENV['SESSION_SECRET'],
      expire_after: 86400,
    }

    register Sinatra::Flash
  end
end
