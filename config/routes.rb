SanityFeatureRunner::Application.routes.draw do
  root :to => 'home#index'
  match '/result', to: 'home#result', via: :post
end
