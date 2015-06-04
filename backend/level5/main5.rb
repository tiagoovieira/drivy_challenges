require "json"
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
# data.json
READ_FILE = 'data.json'

# output.json
WRITE_FILE = 'output.json'

# Deduction Options
DEDUCTION = 400
NO_DEDUCTION = 0

# Price decrease for longer rentals
def apply_discounts(number_of_days)
  return WHOLE_PRICE         if number_of_days <= 1
  return DISCOUNT_10_PERCENT if number_of_days > 1 and number_of_days <= 4
  return DISCOUNT_30_PERCENT if number_of_days > 4 and number_of_days <= 10
  return HALF_DISCOUNT
end

# Calculates the price of the rental
def price(car, days, distance)
  total_price = 0
  days.times do |d|
    discount = apply_discounts(d+1)
    total_price += (car["price_per_day"] * discount) 
  end
  total_price += car["price_per_km"] * distance 
end

# Loads the JSON data
def load_data
  JSON.parse(IO.read(READ_FILE))
end

# Writes the Output into a JSON Data
def write_data(output)
  IO.write( WRITE_FILE, JSON.pretty_generate(output))
end

# Calculates the Commission
def add_commission(price, days)
  commissions = price * COMMISSION_PERCENTAGE
  insurance = commissions * INSURANCE_COMMISSION_PERCENTAGE
  assistence = days * ASSISTENCE_FEE
  drivy = commissions - insurance - assistence
  { insurance_fee: insurance.to_i, 
    assistance_fee: assistence.to_i, 
    drivy_fee: drivy.to_i }
end

def add_options(deductible, days)
  options = DEDUCTION * days  if deductible == true
  options = NO_DEDUCTION      if deductible == false
  {deductible_reduction:  options}
end

# Calculates the number of days of the rental
def number_of_days(rental)
  end_date   = Date.parse(rental["end_date"])
  start_date = Date.parse(rental["start_date"])
  number_of_days = (end_date - start_date+1).to_i
end

def correspondent_payment(who, amount)  
  who == "driver" ? type = "debit" : type = "credit"
  {who: who, type: type, amount: amount}
end

def main5
  hash = load_data
  output = {"rentals": []}
  hash["rentals"].each do |rental|
    number_of_days = number_of_days(rental)
    rental_price = 0
    hash["cars"].detect  do |car|  
      if car["id"] == rental["car_id"]
        rental_price = (price(car,number_of_days,rental["distance"])).to_i
      end
    end
    commissions = add_commission(rental_price, number_of_days)
    deductible_reductions = add_options(rental["deductible_reduction"], number_of_days)[:deductible_reduction]
    total_price = rental_price + deductible_reductions
    owner_fee = (rental_price - rental_price * 0.3).to_i
    drivy_total_fee = commissions[:drivy_fee] + deductible_reductions
    output[:rentals] << { id: rental["id"], 
                          actions: [correspondent_payment("driver",total_price), 
                                    correspondent_payment("owner", owner_fee),
                                    correspondent_payment("insurance", commissions[:insurance_fee]),
                                    correspondent_payment("assistance", commissions[:assistance_fee]),
                                    correspondent_payment("drivy", drivy_total_fee)]} 
  end
  write_data(output)
end

# Run the main function
main5