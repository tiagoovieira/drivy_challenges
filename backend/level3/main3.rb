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

def main3
  hash = load_data
  output = {rentals: []}
  hash["rentals"].each do |rental|
    number_of_days = RentalCalc.number_of_days(rental)
    rental_price = 0
    hash["cars"].detect  do |car|  
      if car["id"] == rental["car_id"]
        rental_price = (RentalCalc.price_w_discounts(car,number_of_days,rental["distance"])).to_i
      end
    end
    output[:rentals] << { id: rental["id"], 
                          price: rental_price, 
                          commission: RentalCalc.add_commission(rental_price, number_of_days) }
  end
  write_data(output)
end

# Run the function
main3