Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match '/sagepayform/show/:order_id/:payment_method_id' => 'sagepayform#show', :as => :sagepayform_show
  match '/sagepayform/comeback(/:server)' => 'checkout#comeback', :as => :sagepayform_comeback
  match '/sagepayform/payment_failure' => 'checkout#sagepayform_payment_failure', :as => :sagepayform_payment_failure
end
