require "open3"
require_relative "./monitor/syscall"
require_relative "./monitor/temperature"

class Monitor
  def run
    loop do
      log(temperatures)

      not_safe_temperatures = temperatures.select { |temp| temp.unsafe? }
      notify_temperatures_not_safe(not_safe_temperatures) if not_safe_temperatures.size > 0

      sleep(10)
    end
  end

  def temperatures
    @temperatures ||= begin
      temperature_values = Syscall.fetch_temperature_values
      temperature_sources = Syscall.fetch_temperature_sources

      return {} if temperature_values.size != temperature_sources.size

      data = []
      (0...(temperature_values.size)).each do |idx|
        data[idx] = Temperature.new(temperature_sources[idx], temperature_values[idx])
      end
      data.sort_by { |temp| -temp.value }
    end
  end

  def log(temperatures)
    temperatures_serialized = temperatures.each { |temp| temp.to_s }.join("\n")

    puts "#{Time.now.to_s}: \n"\
         "#{temperatures_serialized}\n\n"
  end

  def notify_temperatures_not_safe(temperatures)
    body = "Not safe: "
    body += temperatures.each { |temp| temp.to_s }.join(",")
    Syscall.send_desktop_notification("TEMPERATURE ALERT", body)
  end
end
