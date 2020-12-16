Rails.application.routes.draw do
  resource :painters, only: [:show, :update]
end
