#!/opt/flight/bin/ruby
require 'yaml'
require 'tempfile'

inputs = ARGV
node = ARGV[0]
id = ARGV[1]

node = YAML.load_file("/root/flight-hunter/var/parsed/#{id}.yaml")

def editor_command
  ENV.fetch('EDITOR') { 'vi' }
end

content_file = Tempfile.new 'node_content'
content_file.puts node['content']
content_file.close
system "#{editor_command} #{content_file.path}"
node['content'] = File.read content_file.path
File.open("/root/flight-hunter/var/parsed/#{id}.yaml", 'w') { |file| file.write(YAML.dump node) }
