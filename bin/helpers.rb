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

  input = gets.chomp

  while !valid_answers.include?(input)
    puts 'Invalid input, please try again.'
    input = gets.downcase.chomp
  end

  input
end
