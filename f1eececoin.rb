require 'net/http'
require 'digest'
require 'securerandom'
require 'thread'

MY_NAME = 'andrew'
CURRENT_COIN_URI = URI('https://fleececoin.herokuapp.com/current')
COIN_SUBMISSION_URI = URI('https://fleececoin.herokuapp.com/coins')
BENCH_LOOPS = 100_000

abort_attempt = true
current_coin = Net::HTTP.get(CURRENT_COIN_URI)

while(true)
  maybe_coin = ''

  if abort_attempt
    # current_coin has already been set
    abort_attempt = false
  else
    current_coin = Net::HTTP.get(CURRENT_COIN_URI)
  end

  start_of_string = current_coin + ',' + MY_NAME + ','
  random_number = SecureRandom.random_number(1000)
  random_string = random_number.to_s(36)

  check_current_coin_thread = Thread.new do
    new_current_coin = current_coin

    response = Net::HTTP.get_response(CURRENT_COIN_URI)
    new_current_coin = response.read_body if response.code == '200'

    while(new_current_coin == current_coin)
      sleep(1)

      response = Net::HTTP.get_response(CURRENT_COIN_URI)
      if response.code == '200'
        puts response.read_body
        new_current_coin = response.read_body
      end
    end

    current_coin = new_current_coin
    abort_attempt = true
  end

  # decrease priority, not that important
  check_current_coin_thread.priority = -20


  start_time = nil
  iterations = 0

  while !maybe_coin.start_with?('f1eece') && !abort_attempt
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

  if abort_attempt
    puts "Too slow, lost round"
  else
    response = Net::HTTP.post_form(COIN_SUBMISSION_URI, "coin" => start_of_string + random_string)

    puts "RESULTS"
    puts maybe_coin
    puts response.to_s
  end

  if check_current_coin_thread.alive?
    Thread.kill(check_current_coin_thread)
  end
end

