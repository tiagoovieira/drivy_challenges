module RentalCalc
  require "date"

  # Discounts 
  HALF_DISCOUNT = 0.5
  DISCOUNT_30_PERCENT = 0.7
  DISCOUNT_10_PERCENT = 0.9
  WHOLE_PRICE = 1

  # Commissions
  INSURANCE_COMMISSION_PERCENTAGE = 0.5
  COMMISSION_PERCENTAGE = 0.3
  ASSISTENCE_FEE = 100 # 1€/km

  # Deduction Options
  DEDUCTION = 400
  NO_DEDUCTION = 0

  # Price decrease for longer rentals
  def self.apply_discounts(number_of_days)
    return WHOLE_PRICE         if number_of_days <= 1
    return DISCOUNT_10_PERCENT if number_of_days > 1 and number_of_days <= 4
    return DISCOUNT_30_PERCENT if number_of_days > 4 and number_of_days <= 10
    return HALF_DISCOUNT
  end

  # Calculates the number of days of the rental
  def self.number_of_days(rental)
    end_date   = Date.parse(rental["end_date"])
    start_date = Date.parse(rental["start_date"])
    number_of_days = (end_date - start_date+1).to_i
  end

  # Calculates the price of the rental
  def self.price(car, days, distance)
    car["price_per_day"] * days + car["price_per_km"] * distance 
  end

  def self.price_w_discounts(car, days, distance)
    total_price = 0
    days.times do |d|
      discount = apply_discounts(d+1)
      total_price += (car["price_per_day"] * discount) 
    end
    total_price += car["price_per_km"] * distance 
  end

  # Calculates the Commission
  def self.add_commission(price, days)
    commissions = price * COMMISSION_PERCENTAGE
    insurance = commissions * INSURANCE_COMMISSION_PERCENTAGE
    assistence = days * ASSISTENCE_FEE
    drivy = commissions - insurance - assistence
    { insurance_fee: insurance.to_i, 
      assistance_fee: assistence.to_i, 
      drivy_fee: drivy.to_i }
  end

  def self.add_options(deductible, days)
    options = DEDUCTION * days  if deductible == true
    options = NO_DEDUCTION      if deductible == false
    {deductible_reduction:  options}
  end


end