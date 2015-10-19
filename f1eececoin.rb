require 'net/http'
require 'digest'
require 'securerandom'

# Debugging
require 'pry'

MY_NAME = 'andrew'
CURRENT_COIN_URI = URI('https://fleececoin.herokuapp.com/current')
COIN_SUBMISSION_URI = URI('https://fleececoin.herokuapp.com/coins')
BENCH_LOOPS = 100_000

current_coin = Net::HTTP.get(CURRENT_COIN_URI)

random_number = SecureRandom.random_number(1000)
random_string = random_number.to_s(36)

start_time = nil
iterations = 0
start_of_string = "#{current_coin},#{MY_NAME},"
maybe_coin = ''

while !maybe_coin.start_with?('f1eece')
  # BENCHMARKING
  if iterations % BENCH_LOOPS == 0
    end_time = Time.now
    puts "#{BENCH_LOOPS} in #{(end_time - start_time) * 1000} milliseconds" unless start_time.nil?
    start_time = Time.now
  end
  iterations += 1
  # END BENCHMARKING


  random_string.next!
  maybe_coin = Digest::SHA256.hexdigest(start_of_string + random_string)
end

puts maybe_coin
puts random_string

response = Net::HTTP.post_form(COIN_SUBMISSION_URI, "coin" => "#{current_coin},#{MY_NAME},#{random_string}")
puts response.to_s

