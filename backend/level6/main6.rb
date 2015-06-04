require "json"
require "date"

# Price decrease for longer rentals
def apply_discounts(number_of_days)
  return 1   if number_of_days <= 1
  return 0.9 if number_of_days > 1 and number_of_days <= 4
  return 0.7 if number_of_days > 4 and number_of_days <= 10
  return 0.5 
end

# Calculates the price of the rental
def price(car, days, distance)
  total_price = 0
  days.times do |d|
    discount = apply_discounts(d+1)
    total_price += (car["price_per_day"] * discount) 
  end
  total_price += car["price_per_km"] * distance 
  total_price
end

def add_options(deductible, days)
  
  options = 400 * days if deductible == true
  options = 0 if deductible == false

  {"deductible_reduction":  options}
end

def add_commission(price, days)
  commissions = price * 0.3
  insurance = commissions * 0.5
  commissions = commissions - insurance
  assistence = days * 100
  drivy = commissions - assistence

   { "insurance_fee": insurance.to_i, assistance_fee: assistence.to_i, "drivy_fee": drivy.to_i }
end


# Calculates the number of days of the rental
def number_of_days(rental)
  end_date   = Date.parse(rental["end_date"])
  start_date = Date.parse(rental["start_date"])
  number_of_days = (end_date - start_date+1).to_i
end


def correspondent_payment(who, amount)
  if who == "driver" 
    type = "debit"
   else 
    type = "credit"
  end
  {who: who, type: type, amount: amount}
end

def update(original, mod)

end

hash = JSON.parse(IO.read('data.json'))


output = {"rental_modifications": []}
hash["rentals"].each do |rental|
  rental_price = 0
  hash["cars"].detect  do |car|  
    if car["id"] == rental["car_id"]
      hash["rental_modifications"].detect do |mod|
        if mod["rental_id"] == rental["id"]
          puts "#{rental}\n"
          if mod.has_key?("start_date")
            rental["start_date"] = mod["start_date"]
          elsif mod.has_key?("end_date")
            rental["end_date"] = mod["end_date"]
          elsif mod.has_key?("distance")
            rental["distance"] = mod["distance"]
          end
          puts "#{rental}\n"
          number_of_days = number_of_days(rental)
          rental_price = (price(car,number_of_days,rental["distance"])).to_i

          commissions = add_commission(rental_price, number_of_days)
          deductible_reductions = add_options(rental["deductible_reduction"], number_of_days)[:deductible_reduction]
          total_price = rental_price + deductible_reductions
          output[:rental_modifications] << {id: mod["id"],
                                            rental_id: rental["id"], 
                                            actions: [correspondent_payment("driver",total_price), 
                                                      correspondent_payment("owner",(rental_price - rental_price * 0.3).to_i),
                                                      correspondent_payment( "insurance", commissions[:insurance_fee]),
                                                      correspondent_payment("assistance", commissions[:assistance_fee]),
                                                      correspondent_payment("drivy",commissions[:drivy_fee]+deductible_reductions)]} 
        end
      end
    end
  end
  
end


IO.write( 'output5.json', JSON.pretty_generate(output))