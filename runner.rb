pid1 = fork do
  exec('/Users/akampjes/.rbenv/shims/ruby f1eececoin.rb')
end

pid2 = fork do
  exec('/Users/akampjes/.rbenv/shims/ruby f1eececoin.rb')
end
