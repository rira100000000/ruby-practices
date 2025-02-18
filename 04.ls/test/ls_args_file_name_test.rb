# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class ListArgsFileNameTest < Minitest::Test
  def test_make_display_list_when_args_file_name
    assert_equal "#{__dir__}/test_data/01_file  ", make_display_list(parse_option)[0]
  end
end
