Rails.application.routes.draw do
  resource :painters, only: [:show, :create]
end
