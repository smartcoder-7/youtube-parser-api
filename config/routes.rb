Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      post 'upload' => 'uploads#upload'
    end
  end
end
