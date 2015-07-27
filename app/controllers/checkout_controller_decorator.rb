Spree::CheckoutController.class_eval do

  before_filter :redirect_for_sagepayform, :only => :update

  def sagepayform_payment_failure
    flash[:error] ="Payment Failed."
    redirect_to edit_order_path(@order)
  end


  def comeback
    payment_method = Spree::PaymentMethod.find(params[:pmid])

    unless payment_method
      raise "Invalid Return Data"
    end

    # Get paymnt method
    decrypted_data = parse_decrypted_string(SagepayProtocol3::Encryption.decrypt(payment_method.preferred_encryption_key, params['crypt']))

    # raise decrypted_data.to_yaml

    @order = Spree::Order.find(decrypted_data["VendorTxCode"])

    if @order
      unless @order.payments.where(:source_type => 'Spree::BillingIntegration::Sagepayform').present?

        # skrill_transaction = SkrillTransaction.new

        payment = @order.payments.create({:amount => @order.total,
                                          :response_code => decrypted_data,
                                          :payment_method => payment_method},
                                         :without_protection => true)

        payment.started_processing!
        payment.pend!

        raise "payment not Found"
      end

      until @order.state == "complete"
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      # Check Payments and mark as paid if matches
      payment = @order.payments.where(:source_type => 'Spree::BillingIntegration::Sagepayform', :state => "pending").first!

      if payment
        payment_db = Spree::Payment.find(payment.id)
        # Update Payment status
        if payment_db.amount.to_f == decrypted_data["Amount"].to_f
          if (decrypted_data["Status"] == "OK" || decrypted_data["Status"] == "AUTHENTICATED" || decrypted_data["Status"] == "REGISTERED")
            payment_db.state = "completed"
            payment_db.save
          elsif decrypted_data["Status"] == "NOTAUTHED"
            flash[:error] = "The Payment was not authorised."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "ABORT"
            flash[:error] = "The Sagepay Payment was aborted."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "MALFORMED"
            flash[:error] = "The Sagepay Payment process failed due to an error (MALFORMED)."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "INVALID"
            flash[:error] = "The Sagepay Payment process failed due to an error, (INVALID)."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "REJECTED"
            flash[:error] = "The Sagepay Payment was rejected, please check that the address and card details are correct."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "ERROR"
            flash[:error] = "The Sagepay Payment process failed due to an error, (ERROR)."
            redirect_to edit_order_path(@order)
          elsif decrypted_data["Status"] == "INVALID"
            flash[:error] = "The Sagepay Payment process failed due to an error, (INVALID)."
            redirect_to edit_order_path(@order)
          end
        else
          flash[:error] = "The payment amount does not reconcile correctly. This order will be reviewed by an administrator."
          redirect_to edit_order_path(@order)
        end
      else
        raise "No Payment Found"
      end

      flash.notice = t(:order_processed_successfully)
      flash[:commerce_tracking] = "nothing special"

      # raise "order found, order updated "
      redirect_to completion_route
    else

      # raise "order not found"
      flash[:error] = "Order Not Found"
      redirect_to edit_order_path(@order)

    end
  end

  private

  def redirect_for_sagepayform
    return unless params[:state] == "payment"
    @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    if @payment_method && (@payment_method.kind_of?(Spree::BillingIntegration::SagepayformV3) || @payment_method.kind_of?(Spree::BillingIntegration::Sagepayform))

      @order.update_attributes(object_params)
      redirect_to sagepayform_show_path(:order_id => @order.id, :payment_method_id => @payment_method.id)
    end
  end

  def decrypt_response(data, key)
    raise 'No key provided' if key.blank?

    key *= (data.bytesize.to_f / key.bytesize.to_f).ceil
    key = key[0, data.bytesize]
    data.bytes.zip(key.bytes).map { |b1, b2| (b1 ^ b2).chr }.join
  end

  def parse_decrypted_string(data)
    @raw = data.to_s
    @data = {}
    for line in @raw.split('&')
      key, value = *line.scan(%r{^([A-Za-z0-9_.]+)\=(.*)$}).flatten
      @data[key] = CGI.unescape(value)
    end

    @data
  end
end