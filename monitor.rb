require 'open3'
require './temperature'
require './notification'

TEMPERATURE_VALUES_COMMAND = 'cat /sys/class/thermal/thermal_zone*/temp'
TEMPERATURE_NAMES_COMMAND = 'cat /sys/class/thermal/thermal_zone*/type'

def fetch_temperature_values
  stdout_and_stderr, status = Open3.capture2e(TEMPERATURE_VALUES_COMMAND)
  return [] if status.exitstatus != 0

  stdout_and_stderr.split("\n").map do |line|
    trimmed_line = line.strip
    trimmed_line.to_f / 1000.0
  end
end

def fetch_temperature_sources
  stdout_and_stderr, status = Open3.capture2e(TEMPERATURE_NAMES_COMMAND)
  return [] if status.exitstatus != 0

  stdout_and_stderr.split("\n").map do |line|
    trimmed_line = line.strip
    trimmed_line
  end
end

def temperatures
  temperature_values = fetch_temperature_values
  temperature_sources = fetch_temperature_sources

  return {} if temperature_values.size != temperature_sources.size

  data = []
  (0...(temperature_values.size)).each do |idx|
    data[idx] = Temperature.new(temperature_sources[idx], temperature_values[idx])
  end
  data
end

def log(temperatures)
  temperatures_serialized = temperatures.each { |temp| temp.to_s }
                                        .join("\n")

  puts "#{Time.now.to_s}: \n"\
       "#{temperatures_serialized}\n\n"
end

def check
  all_temperatures = temperatures.sort_by { |temp| -temp.value }

  log(all_temperatures)

  not_safe_temperatures = all_temperatures.select { |temp| temp.unsafe? }
  notify_temps_not_safe(not_safe_temperatures) if not_safe_temperatures.size > 0
end

while true
  check
  sleep(10)
end
