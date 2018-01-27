# gem install gas_load_tester rest-client
require 'gas_load_tester'
require 'rest-client'

SERVER_URL = "http://128.199.155.167"
rng = Random.new

def print_results(test, test_name)
  num_passed = 0
  num_failed = 0
  times = []
  results = (test.results.flatten)[1]
  results.each do |one_test|
    if one_test.pass
      num_passed += 1
    else
      num_failed += 1
    end
    times << one_test.time
  end
  puts test_name
  puts "Results: #{num_passed} passed #{num_failed} failed"
  puts "Avg: #{times.sum.fdiv(times.size)}s, Max: #{times.max}s"
end

drivers_test = GasLoadTester::Test.new({client: 1000, time: 10})
drivers_test.run do
  RestClient.put(
    "#{SERVER_URL}/drivers/#{rng.rand(1..50000)}/location",
    {
      "latitude": rng.rand(-5.0..5.0),
      "longitude": rng.rand(-5.0..5.0),
      "accuracy": rng.rand(1.0)
    }.to_json,
    {content_type: :json}
  )
end
print_results(drivers_test, "Drivers Test")

customers_test = GasLoadTester::Test.new({client: 200, time: 10})
customers_test.run do
  RestClient.get(
    "#{SERVER_URL}/drivers",
    params: {
      latitude: rng.rand(-5.0..5.0),
      longitude: rng.rand(-5.0..5.0)
    }
  )
end
print_results(customers_test, "Customers Test")
