require 'rubygems'
require 'open3'
require 'flowdock'

# Create a client that uses your personal API token to authenticate
# spelled like it sounds
api_token_client = Flowdock::Client.new(api_token: '<your-token>')

# Create a client that uses a source's flow_token to authenticate. Can only use post_to_thread
# this is from the integration in the console window
flow_token_client = Flowdock::Client.new(flow_token: '<your-token>')

#get our hostname so multiple teabots can get instructions in one room
hostname = Open3.capture3("hostname")
hostname = hostname.to_s
hostname = hostname.split('.')
hostname = hostname[0].sub! '["', ''

#this code can be used to grab flow ID's
#flows = api_token_client.get('/flows')
##puts(flows)

#let the world know we're online
start_msg = "TEABOT ONLINE - ALL KILLER NO FILLER! " + "\n" + "My name is " + hostname
api_token_client.chat_message(flow: '<flow-uuid>', content: start_msg)

#code to pull messages from room
loop do
      sleep(5)
      msgs = api_token_client.get('/flows/<flowname>/messages')
      for obj in msgs do
          obj = obj.to_s
          output = 0
          if obj.include? hostname 
              #parse out the cmd and the time
              obj = obj.split(', ')
              cmd = obj[1]
              cmd = cmd.sub! '"content"=>', ''
              if not cmd.include? ":"
                next
              end
              cmd = cmd.split(':')
              cmd = cmd[1].sub! '"', ''
              time = obj[27]
              time = time.sub! '"created_at"=>', ''
              write_string = cmd + ',' + time
              write_string = write_string.sub! ' ', ''
              test_write_string = write_string + "\n"

              read_flag = 0
              File.open('/tmp/teabot.txt', 'r') do |f1|
                while line = f1.gets
                  if test_write_string == line
                    read_flag = 1
                    break
                  end
                end
              end

              if read_flag == 0
                #this code will be for actual cmd-line commands
                begin
                  output = Open3.capture3(cmd)
                  #puts("----------------")
                  #puts(output)
                  #puts("----------------")
                  api_token_client.chat_message(flow: '<flow_uuid>', content: output)
                  File.open('/tmp/teabot.txt', 'a') do |f2|
                    f2.puts(write_string)
                  end
                rescue 
                  output = "Command failed"
                  api_token_client.chat_message(flow: '<flow_uuid>', content: output)
                  File.open('/tmp/teabot.txt', 'a') do |f2|
                    f2.puts(write_string)
                  end
                end 
              end
          else if obj.include? "teabots"
              #parse out the cmd and the time
              obj = obj.split(', ')
              cmd = obj[1]
              cmd = cmd.sub! '"content"=>', ''
              if not cmd.include? ":"
                next
              end
              cmd = cmd.split(':')
              cmd = cmd[1].sub! '"', ''
              time = obj[27]
              time = time.sub! '"created_at"=>', ''
              write_string = cmd + ',' + time
              write_string = write_string.sub! ' ', ''
              test_write_string = write_string + "\n"

              read_flag = 0
              File.open('/tmp/teabot.txt', 'r') do |f1|
                while line = f1.gets
                  if test_write_string == line
                    read_flag = 1
                    break
                  end
                end
              end

              if read_flag == 0
                #this code will be for teabot commands
                if cmd.include? "list all"
                  output = hostname + " listening"
                end
                #puts("----------------")
                #puts(output)
                #puts("----------------")
                if output != 0
                  api_token_client.chat_message(flow: '<flow_uuid>', content: output)
                  File.open('/tmp/teabot.txt', 'a') do |f2|
                    f2.puts(write_string)
                  end 
                else
                  output = "Teabot cmd not recognized"
                  api_token_client.chat_message(flow: '<flow_uuid>', content: output)
                  File.open('/tmp/teabot.txt', 'a') do |f2|
                    f2.puts(write_string)
                  end 

                end
              end
          end
      end
    end
end
