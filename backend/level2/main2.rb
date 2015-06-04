require "json"
require "date"

# Discounts 
HALF_DISCOUNT = 0.5
DISCOUNT_30_PERCENT = 0.7
DISCOUNT_10_PERCENT = 0.9
WHOLE_PRICE = 1

# data.json
READ_FILE = 'data.json'

# output.json
WRITE_FILE = 'output.json'

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


def main2
  hash = load_data
  output = {rentals: []}
  hash["rentals"].each do |rental|
    number_of_days = number_of_days(rental)
    rental_price = 0
    hash["cars"].detect  do |car|  
      if car["id"] == rental["car_id"]
        rental_price = (price(car,number_of_days,rental["distance"])).to_i
      end
    end
    output[:rentals] << {id: rental["id"], price: rental_price}
  end
  write_data(output)
end

# Run the function
main2