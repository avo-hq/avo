# require 'fileutils'
# require 'pp'

# output_dir = "docs/fields"
# FileUtils.mkdir_p(output_dir)

# Avo::Fields::BaseField.descendants.each do |field|
#   field_name = field.name.demodulize.underscore
#   file_path = File.join(output_dir, "#{field_name}.md")

#   File.open(file_path, "w") do |file|
#     file.puts "# #{field.name}"
#     file.puts
#     file.puts "## Supported Options"
#     file.puts

#     supported_options = field.try(:supported_options)

#     if supported_options.present?
#       formatted_options = PP.pp(supported_options, +"", 60)
#       file.puts "```ruby"
#       file.puts formatted_options
#       file.puts "```"
#     else
#       file.puts "_No supported options available._"
#     end
#   end

#   puts "Generated documentation for: #{field_name}"
# end


# VVVVVVVVVVVVV222222222

require 'fileutils'

output_dir = "docs/fields"
FileUtils.mkdir_p(output_dir)

Avo::Fields::BaseField.descendants.each do |field|
  field_name = field.name.demodulize.underscore
  file_path = File.join(output_dir, "#{field_name}.md")

  supported_options = field.try(:supported_options)

  # Collect all possible keys across all supported options
  all_keys = supported_options&.values&.map(&:keys)&.flatten&.uniq || []

  File.open(file_path, "w") do |file|
    file.puts "# #{field.name}"
    file.puts
    file.puts "## Supported Options"
    file.puts

    if supported_options.present?
      # Header row
      file.puts "| Option | #{all_keys.map(&:to_s).map(&:humanize).join(" | ")} |"
      file.puts "|--------|#{'---|' * all_keys.size}"

      supported_options.each do |option_name, option_config|
        row = [ "`#{option_name}`" ]
        all_keys.each do |key|
          val = option_config[key]
          row << (val.nil? ? "" : "`#{val.inspect}`")
        end
        file.puts "| #{row.join(" | ")} |"
      end
    else
      file.puts "_No supported options available._"
    end
  end

  puts "Generated documentation for: #{field_name}"
end
