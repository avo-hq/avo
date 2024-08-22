# frozen_string_literal: true

class Avo::ForTest::TableRowComponent < Avo::Index::TableRowComponent
  def initialize(**args)
    @args = args
  end

  def args
    @args.merge(header_fields: @header_fields)
  end
end
# TODO: document that need to inherit from  < Avo::Index::TableRowComponent and need to pass @header_files... and explain why
