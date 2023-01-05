# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/wc'

class Word_Count_Test < Minitest::Test
  attr_reader :test_data_dir, :current_dir, :wc_path

  def setup
    @test_data_dir = "#{__dir__}/test_data"
    @current_dir = Dir.pwd
    Dir.chdir(test_data_dir)
    @wc_path = "#{__dir__.sub!(%r{/test$}, '')}/lib/wc.rb"
  end

  def teardown
    Dir.chdir(current_dir)
  end

  def test_file_exists
    output = `ruby #{wc_path} 01_file.txt`
    expected_str = "  12 18 146 01_file.txt\n"
    assert_equal output, expected_str
  end

  def test_multiple_files_exist
    output = `ruby #{wc_path} 01_file.txt 03_file.txt`
    expected_str =
    "   12  18 146 01_file.txt\n"\
    "   99  99 198 03_file.txt\n"\
    "  111 117 344 total\n"
    assert_equal output, expected_str
  end

  def test_file_not_exists
    output = `ruby #{wc_path} not_exist_file`
    expected_str = "wc: not_exist_file: No such file or directory\n"
    assert_equal output, expected_str
  end

  def test_specified_directory
    output = `ruby #{wc_path} 00_dir`
    expected_str = 
      "wc: 00_dir: Is a directory\n"\
      "  0 0 0 00_dir\n"
    assert_equal output, expected_str
  end
end
