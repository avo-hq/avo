require 'fileutils'

def app_root
  root = File.expand_path('..', __dir__)

  FileUtils.chdir(root) do
    yield
  end
end

def run!(*args)
  system(*args) || abort("\nCommand `#{args}` failed")
end

def header(msg)
  divider = '=' * msg.length

  puts "\n\e\u001b[1m#{divider}\e[0m"
  puts "\u001b[1m#{msg}\e[0m"
  puts "\e\u001b[1m#{divider}\e[0m\n\n"
end

def ask(question:, valid_answers: [])
  puts "\n#{question} (#{valid_answers.join('/')})"
  # An uppercase option is treated as a default answer.  Otherwise, we disregard case, and always
  # return the answer in lowercase.
  default_answer = valid_answers.select { |val| val == val.upcase }.first&.downcase

  valid_answers.map!(&:downcase)

  input = gets.downcase.chomp
  input = default_answer if input == ''

  while !valid_answers.include?(input)
    puts 'Invalid input, please try again.'
    input = gets.downcase.chomp
  end

  input
end
