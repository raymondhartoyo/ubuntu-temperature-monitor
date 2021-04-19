module Syscall
  TEMPERATURE_VALUES_COMMAND = "cat /sys/class/thermal/thermal_zone*/temp".freeze
  TEMPERATURE_NAMES_COMMAND = "cat /sys/class/thermal/thermal_zone*/type".freeze

  NOTIFY_COMMAND = "notify-send".freeze
  NOTIFY_COMMAND_HINTS = "int:transient:1".freeze

  def self.send_desktop_notification(title, body)
    stdout_and_stderr, status = Open3.capture2e(NOTIFY_COMMAND, "--hint", NOTIFY_COMMAND_HINTS, title.to_s, body.to_s)
    raise StandardError, "Cannot send desktop notification, output: #{stdout_and_stderr}" if status.exitstatus != 0
  end

  def self.fetch_temperature_values
    stdout_and_stderr, status = Open3.capture2e(TEMPERATURE_VALUES_COMMAND)
    return [] if status.exitstatus != 0

    stdout_and_stderr.split("\n").map do |line|
      trimmed_line = line.strip
      trimmed_line.to_f / 1000.0
    end
  end

  def self.fetch_temperature_sources
    stdout_and_stderr, status = Open3.capture2e(TEMPERATURE_NAMES_COMMAND)
    return [] if status.exitstatus != 0

    stdout_and_stderr.split("\n").map do |line|
      trimmed_line = line.strip
      trimmed_line
    end
  end
end
