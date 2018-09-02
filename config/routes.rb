Rails.application.routes.draw do
  root 'messages#index'
  post '/callback' => 'messages#callback'
end
