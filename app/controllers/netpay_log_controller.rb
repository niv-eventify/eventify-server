class NetpayLogController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token, :only => [:create]
  actions :create

  def create
    build_resource
    unless Netpay::HostedPage.validate_response(params)
      raise ActiveRecord::RecordInvalid.new(resource)
    end
    resource.replyCode = params[:replyCode]
    resource.replyDesc = params[:replyDesc]
    resource.trans_id = params[:trans_id]
    resource.trans_date = params[:trans_date]
    resource.trans_amount = params[:trans_amount]
    resource.trans_currency = params[:trans_currency]
    resource.trans_installments = params[:trans_installments]
    resource.trans_refNum = params[:trans_refNum]
    resource.client_id = params[:client_id]
    resource.paymentDisplay = params[:paymentDisplay]
    resource.client_fullName = params[:client_fullName]
    resource.client_phoneNum = params[:client_phoneNum]

    if resource.save!
      payment = Payment.find(resource.trans_refNum)
      begin
        payment.finalize_payment!(params)
      rescue PaymentError
        logger.debug("PaymentError: #{PaymentError}")
      end
      render :nothing => true
    end
  end
end
