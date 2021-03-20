require 'open3'

NOTIFY_COMMAND = 'notify-send'
NOTIFY_HINTS = 'int:transient:1'

NOTIFICATION_TITLE = 'TEMPERATURE ALERT'

def notify(title, body)
  stdout_and_stderr, status = Open3.capture2e(NOTIFY_COMMAND, '--hint', NOTIFY_HINTS, title.to_s, body.to_s)
  raise "Cannot send desktop notification, output: #{stdout_and_stderr}" if status.exitstatus != 0
end

def notify_temps_not_safe(not_safe_temperatures)
  body = "Not safe: "
  body += not_safe_temperatures.each { _1.to_s }.join(',')
  notify(NOTIFICATION_TITLE, body)
end
