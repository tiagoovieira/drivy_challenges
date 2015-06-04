require "json"
require "../rental_calc"

# data.json
READ_FILE = 'data.json'

# output.json
WRITE_FILE = 'output.json'

# Loads the JSON data
def load_data
  JSON.parse(IO.read(READ_FILE))
end

# Writes the Output into a JSON Data
def write_data(output)
  IO.write( WRITE_FILE, JSON.pretty_generate(output))
end

def correspondent_payment(who, amount)  
  who == "driver" ? type = "debit" : type = "credit"
  {who: who, type: type, amount: amount}
end

def main5
  hash = load_data
  output = {"rentals": []}
  hash["rentals"].each do |rental|
    number_of_days = RentalCalc.number_of_days(rental)
    rental_price = 0
    hash["cars"].detect  do |car|  
      if car["id"] == rental["car_id"]
        rental_price = (RentalCalc.price_w_discounts(car,number_of_days,rental["distance"])).to_i
      end
    end
    commissions = RentalCalc.add_commission(rental_price, number_of_days)
    deductible_reductions = RentalCalc.add_options(rental["deductible_reduction"], number_of_days)[:deductible_reduction]
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