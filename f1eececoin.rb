require 'net/http'
require 'digest'
require 'securerandom'
require 'thread'

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

abort_attempt = false

check_current_coin_thread = Thread.new do
  new_current_coin = Net::HTTP.get(CURRENT_COIN_URI)
  while(new_current_coin == current_coin)
    sleep(1)

    new_current_coin = Net::HTTP.get(CURRENT_COIN_URI)
  end

  abort_attempt = true
end

# decrease priority, not that important
check_current_coin_thread.priority = -2

while !maybe_coin.start_with?('f1eece')# && !abort_attempt
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

if check_current_coin_thread.alive?
  Thread.kill(check_current_coin_thread)
end

if abort_attempt
  puts "ABORT ATTEMPT"
end

puts "RESULTS"
puts maybe_coin
puts random_string

response = Net::HTTP.post_form(COIN_SUBMISSION_URI, "coin" => "#{current_coin},#{MY_NAME},#{random_string}")
puts response.to_s

