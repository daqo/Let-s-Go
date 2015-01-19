SimpleAuth::Application.routes.draw do
  resources :statuses, except: [:new, :edit] do
    collection do
      post :list
    end
  end

  resources :users, except: [:new, :edit, :destroy]
  post 'session' => 'session#create'
end
