# frozen_string_literal: true

require 'open3'
require 'socket'
require 'csv'

@log_file = CSV.open('log.csv', 'a')
@log_file << ["Activity", "Timestamp", "Username", "Process name", "Process command line", "PID", "Extra Info"]

def process_test(command)
  # When given a path, the pid is the subshell pid not the command pid
  pid = Process.spawn(command)
  process = Open3.capture2("ps -e -o pid,user,start,comm,cmd -q #{pid}")
  match = process.first.match(/#{Regexp.quote(pid.to_s)}\s*(\w*)\s*(\S*)\s*(\S*)\s*(\S.*)/)
  @log_file << ["Process Spawn", match[2], match[1], match[3], match[4], pid, nil]
end

def file_test(filepath)
  create_file(filepath)
  modify_file(filepath)
  delete_file(filepath)
end

def create_file(filepath)
  @log_file << ["Create file"] + self_process_info + ["Filepath: #{filepath}"]
  File.open(filepath, "w") { |f| f.write "Some lorem ipsum text" }
end

def modify_file(filepath)
  @log_file << ["Modify file"] + self_process_info + ["Filepath: #{filepath}"]
  File.open(filepath, "w") { |f| f.write "Some different lorem ipsum text" }
end

def delete_file(filepath)
  @log_file << ["Delete file"] + self_process_info + ["Filepath: #{filepath}"]
  File.delete(filepath)
end

def network_test
  if @u1.nil?
    @u1 = UDPSocket.new
    @u1.bind("127.0.0.1", 4913)
  end
  @u2 ||= UDPSocket.new
  bytes_sent = @u2.send "a network message", 0, "127.0.0.1", 4913
  @log_file << ["Network Connection"] + self_process_info + ["Destination: 127.0.0.1:4913 | Source: 127.0.0.1:4913 | Protocol: UDP | Bytes sent: #{bytes_sent}"]
end

def self_process_info
  process = Open3.capture2("ps -e -o pid,user,start,comm,cmd -q #{Process.pid}")
  match = process.first.match(/#{Regexp.quote(Process.pid.to_s)}\s*(\w*)\s*(\S*)\s*(\S*)\s*(\S.*)/)
  [match[2], match[1], match[3], match[4], Process.pid]
end

input = 9
while input != 0
  puts "Select an option:"
  puts "1: Spawn Process"
  puts "2: File Test"
  puts "3: Generate Network Activity"
  puts "0: Exit"
  input = gets.chomp.to_i
  case input
  when 1
    puts "Enter command for new process:"
    process_test(gets.chomp)
  when 2
    puts "Enter filename with path:"
    file_test(gets.chomp)
  when 3
    network_test
  else
   input = 0 
  end
end
puts "Exiting"

@log_file.close
