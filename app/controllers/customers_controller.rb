class CustomersController < ApplicationController
  def index
  end

  def create
    begin
      customer = Conekta::Customer.create({
        name: params['customer_name'],
        email: params['customer_email'],
        phone: params['customer_phone']
      })
      redirect_to customer_path(customer.id)
    rescue Conekta::ParameterValidationError => e
      puts e.message_to_purchaser
    end
  end

  def show
    begin
      @customer = Conekta::Customer.find(params[:id])
    rescue Conekta::ParameterValidationError => e
      puts e.message_to_purchaser
    end

  end

  def update
    begin
      customer = Conekta::Customer.find(params[:id])
      customer.create_card(token: params["conektaTokenId"])
      redirect_to customer_path(customer.id)
    rescue Conekta::ParameterValidationError => e
      e.message_to_purchaser
    end
  end

  def charge
    begin
      @customer = Conekta::Customer.find(params[:id])
      @charge = Conekta::Charge.create({
        amount: params['chargeInCents'],
        currency: "MXN",
        description: "Pizza Delivery at test",
        reference_id: "001-id-test",
        details:
        {
          email: @customer.email,
          line_items: [
            { name: 'Pizza at test',
              description: 'A pizza test description',
              unit_price: params['chargeInCents'],
              quantity: 1,
              sku: 'pizza-test',
              type: 'pizza'
          }
          ]
        },
        card: params['customer_card_id']
      })
    rescue Conekta::ParameterValidationError => e
      puts e.message_to_purchaser
      #alguno de los parámetros fueron inválidos
    rescue Conekta::ProcessingError => e
      puts e.message_to_purchaser
      #la tarjeta no pudo ser procesada
    rescue Conekta::Error
      puts e.message_to_purchaser
      #un error ocurrió que no sucede en el flujo normal de cobros como por ejemplo un auth_key incorrecto
    end
  end
end
