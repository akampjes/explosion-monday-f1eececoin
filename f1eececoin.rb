require 'net/http'
require 'digest'
require 'securerandom'
require 'thread'

MY_NAME = 'andrew'
CURRENT_COIN_URI = URI('https://fleececoin.herokuapp.com/current')
COIN_SUBMISSION_URI = URI('https://fleececoin.herokuapp.com/coins')
BENCH_LOOPS = 100_000

def get_current_coin
  response = Net::HTTP.get_response(CURRENT_COIN_URI)
  if response.code == '200'
    response.read_body
  else
    nil
  end
end


abort_attempt = false
current_coin = get_current_coin

# Thread that checks if the current coin has changed
# Sets abort_attempt from inside here if we need to stop
check_current_coin_thread = Thread.new do
  # Getting current coin may fail, so use the exsting coin
  new_current_coin = get_current_coin || current_coin
  while(new_current_coin == current_coin)
    sleep(1)

    coin = get_current_coin
    new_current_coin = coin unless coin.nil?
  end

  current_coin = new_current_coin
  abort_attempt = true
end
# decrease priority, therad not that important
check_current_coin_thread.priority = -20


while(true)
  maybe_coin = ''
  abort_attempt = false

  start_of_string = current_coin + ',' + MY_NAME + ','
  random_string = SecureRandom.random_number(100_000).to_s(36)

  while !maybe_coin.start_with?('f1eece') && !abort_attempt
    random_string.next!
    maybe_coin = Digest::SHA256.hexdigest(start_of_string + random_string)
  end

  unless abort_attempt
    response = Net::HTTP.post_form(COIN_SUBMISSION_URI, "coin" => start_of_string + random_string)
    puts 'woncoin'

    # Since we just worked out the coin,
    # we can save what the coin must be and save us some time
    current_coin = maybe_coin
  end
end

