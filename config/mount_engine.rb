Foreman::Application.routes.draw do
  mount Dockerro::Engine, :at => '/', :as => 'dockerro'
end
