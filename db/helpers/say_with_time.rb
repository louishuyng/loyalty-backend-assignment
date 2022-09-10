def say(message, subitem: false)
  puts "#{subitem ? '   ->' : '--'} #{message}"
end

def say_with_time(message)
  say(message)
  result = nil
  time = Benchmark.measure { result = yield }
  say format('%<time>.4fs', time: time.real), subitem: true
  result
end
