module Spree


  class SagepayformController < ApplicationController

    skip_before_filter :verify_authenticity_token, :only => [:comeback, :comeback_s2s]

    def show
      if params[:payment_method_id] and Spree::PaymentMethod.exists? params[:payment_method_id]
        @payment_method = Spree::PaymentMethod.find params[:payment_method_id]
      else
        flash[:error] = "ERROR, parameter payment_method_id wrong, the method of payment id=#{params[:payment_method_id]} non esiste !"
        redirect_to checkout_state_url(:payment)
      end

      @shop_login = @payment_method.preferred_login
      @server = @payment_method.preferred_server

      if params[:order_id] and Spree::Order.exists? params[:order_id]
        @order = Spree::Order.find params[:order_id]
      else
        flash[:error] = "ERROR, parameter payment_method_id wrong, the method of payment id=#{params[:order_id]} non esiste !"
        redirect_to checkout_state_url(:payment)
      end

      # Assume thjat there is a payment record for the order
      payment = @order.payments.where(:state => "checkout",
                                      :payment_method_id => @payment_method.id).first

      unless payment
        raise "Payment not found!"
      end

      # Update Payment info
      payment.state = "pending"
      payment.source_type = "Spree::BillingIntegration::Sagepayform"
      payment.save


      # :amount, :currency, :test, :credential2, :credential3, :credential4, :country, :account_name, :transaction_type
      spf = Spree::BillingIntegration::Sagepayform.new()

      spfh = ActiveMerchant::Billing::Integrations::SagePayForm::Helper.new(@order, @payment_method.preferred_login)

      #
      spfh.add_field("EncryptKey", @payment_method.preferred_encryption_key)
      spfh.add_field("Vendor", @payment_method.preferred_login)
      spfh.add_field("VendorTxCode", @order.id)
      spfh.add_field("Amount", @order.total)
      spfh.add_field("Currency", "GBP")

      # Loop items in the order

      str_desc = "Items Ordered : "
      @order.line_items.each do |li|
        str_desc = str_desc + li.variant.name + " X " + li.quantity.to_s + ". "
      end

      # str_desc = "This is a test with some longer text here an there, and anywhere"

      #raise str_desc

      spfh.add_field("Description", str_desc)

      spfh.add_field("SuccessURL", "#{request.protocol}#{request.host_with_port}/sagepayform/comeback?pmid=" + @payment_method.id.to_s)
      spfh.add_field("FailureURL", "#{request.protocol}#{request.host_with_port}/sagepayform/payment_failure")
      spfh.add_field("VendorEMail", "sales@tubchairs.com")
      spfh.add_field("SendEMail", "1")

      spfh.add_field("CustomerName", @order.bill_address.firstname + " " + @order.bill_address.firstname)
      spfh.add_field("CustomerEmail", @order.email)

      spfh.add_field("BillingSurname", @order.bill_address.lastname)

      spfh.add_field("BillingFirstnames", @order.bill_address.firstname)
      spfh.add_field("BillingAddress1", @order.bill_address.address1)
      spfh.add_field("BillingAddress2", @order.bill_address.address2)
      spfh.add_field("BillingCity", @order.bill_address.city)
      spfh.add_field("BillingPostCode", @order.bill_address.zipcode)
      spfh.add_field("BillingCountry", @order.bill_address.country.iso)
      spfh.add_field("BillingState", "")
      spfh.add_field("BillingPhone", @order.bill_address.phone)

      spfh.add_field("DeliverySurname", @order.ship_address.lastname)
      spfh.add_field("DeliveryFirstnames", @order.ship_address.firstname)
      spfh.add_field("DeliveryAddress1", @order.ship_address.address1)
      spfh.add_field("DeliveryAddress2", @order.ship_address.address2)
      spfh.add_field("DeliveryCity", @order.ship_address.city)
      spfh.add_field("DeliveryPostCode", @order.ship_address.zipcode)
      spfh.add_field("DeliveryCountry", @order.ship_address.country.iso)
      spfh.add_field("DeliveryState", "")
      spfh.add_field("DeliveryPhone", @order.ship_address.phone)

      str_basket = (@order.line_items.count + 1).to_s + ":"

      @order.line_items.each do |li|
        str_basket = str_basket + li.variant.name + ":"
        str_basket = str_basket + li.quantity.to_s + ":"
        str_basket = str_basket + li.variant.price.to_s + ":"
        str_basket = str_basket + ":"
        str_basket = str_basket + ":"
        str_basket = str_basket + (li.quantity * li.variant.price).to_s + ":"
      end

      str_basket = str_basket + "Delivery"
      str_basket = str_basket + ":"
      str_basket = str_basket + ":"
      str_basket = str_basket + ":"
      str_basket = str_basket + ":"
      str_basket = str_basket + "0:"

      # raise str_basket

      spfh.add_field("Basket", str_basket)
      spfh.add_field("AllowGiftAid", "0")

      spfh.add_field("ApplyAVSCV2", "0")
      spfh.add_field("Apply3DSecure", "2")
      spfh.add_field("BillingAgreement", "0")

      # raise spfh.form_fields.to_yaml
      # raise @payment_method.preferred_encryption_key

      spf_url = service_url(@payment_method) + spf.redirect_url(spfh)

      # raise spf.provider.to_yaml

      #t = Sage::TransactionData.new(
      #    :amount => @order.total,
      #    :currency => 242,
      #    :shop_transaction_id => @order.number
      #)

      redirect_to spf_url

      # Get the first encryption
      # t = c.encrypt(t)
      # Check for errors
      #unless t[:error_code].nil?
      #  flash[:error] = "ERROR on first encryption. #{t[:error_code]} / #{t.inspect}"
      #  redirect_to spf_url
      #end
      ## Dati per il form
      #@a = @shop_login
      #@b = t[:encrypted_str]
      #@form_url = (@server == 'test') ? "https://testecomm.sella.it/gestpay/pagam.asp" : "https://ecomm.sella.it/gestpay/pagam.asp"

    end

    def service_url(payment_method)
      mode = payment_method.preferred_server

      # raise payment_method.preferred_server
      case mode
        when "production"
          'https://live.sagepay.com/gateway/service/vspform-register.vsp'
        when "test"
          'https://test.sagepay.com/gateway/service/vspform-register.vsp'
        when "simulate"
          'https://test.sagepay.com/Simulator/VSPFormGateway.asp'
        else
          raise StandardError, "Integration mode set to an invalid value: #{mode}"
      end
    end


    private


  end
end