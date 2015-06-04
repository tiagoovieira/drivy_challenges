require "json"
require "date"

# data.json
READ_FILE = 'data.json'

# output.json
WRITE_FILE = 'output.json'

# Calculates the price of the rental
def price(car, days, distance)
  car["price_per_day"] * days + car["price_per_km"] * distance 
end


# Calculates the number of days of the rental
def number_of_days(rental)
  end_date   = Date.parse(rental["end_date"])
  start_date = Date.parse(rental["start_date"])
  number_of_days = (end_date - start_date+1).to_i
end

# Loads the JSON data
def load_data
  JSON.parse(IO.read(READ_FILE))
end

# Writes the Output into a JSON Data
def write_data(output)
  IO.write( WRITE_FILE, JSON.pretty_generate(output))
end

def main1
  hash = load_data
  output = {rentals: []}
  hash["rentals"].each do |rental|
    number_of_days = number_of_days(rental)
    rental_price = 0
    hash["cars"].detect  do |car|  
      if car["id"] == rental["car_id"]
        rental_price = price(car,number_of_days,rental["distance"])
      end
    end
    output[:rentals] << {id: rental["id"], price: rental_price}
  end
  write_data(output)
end

# Run the main function
main1