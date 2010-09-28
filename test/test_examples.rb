root_dir = File.dirname(File.expand_path(__FILE__)) + '/../'
examples_output = `find -s #{root_dir}examples -iname '*.rb' -exec ruby {} \\;`
expected_output = File.read("#{root_dir}test/expected_examples_output.txt")
if expected_output != examples_output
  puts "FAILED: Examples do not produce same output as expected.\n"
  raise StandardError, "FAILED"
end
puts "SUCCEEDED.\n"
