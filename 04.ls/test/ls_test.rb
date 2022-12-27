# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class ListTest < Minitest::Test
  attr_reader :test_data_dir, :current_dir, :ls_path

  def setup
    @test_data_dir = "#{__dir__}/test_data"
    @current_dir = Dir.pwd
    Dir.chdir(test_data_dir)
    @ls_path = "#{__dir__.sub!(%r{/test$}, '')}/lib/ls.rb"
  end

  def teardown
    Dir.chdir(current_dir)
  end

  def test_current_dir_list_display
    output = `ruby #{ls_path}`
    true_str =
      "00_file  04dir    13_file            \n"\
      "00dir    05_file  14_file            \n"\
      "01_file  06_file  15_file            \n"\
      "01dir    07_file  16_file            \n"\
      "02_file  08_file  17_file            \n"\
      "02dir    09_file  18_file            \n"\
      "03_file  10_file  19_file            \n"\
      "03dir    11_file  attr_file          \n"\
      "04_file  12_file  make_test_file.rb  \n"
    assert_equal true_str, output
  end

  def test_current_dir_list_display_with_option_a
    output = `ruby #{ls_path} -a`
    true_str =
      ".        03_file  12_file            \n"\
      ".dir     03dir    13_file            \n"\
      ".dir2    04_file  14_file            \n"\
      ".file    04dir    15_file            \n"\
      ".file2   05_file  16_file            \n"\
      "00_file  06_file  17_file            \n"\
      "00dir    07_file  18_file            \n"\
      "01_file  08_file  19_file            \n"\
      "01dir    09_file  attr_file          \n"\
      "02_file  10_file  make_test_file.rb  \n"\
      "02dir    11_file  \n"
    assert_equal true_str, output
  end

  def test_dir_list_diplay_with_dir_path_and_option_a
    output = `ruby #{ls_path} #{test_data_dir} -a`
    true_str =
      ".        03_file  12_file            \n"\
      ".dir     03dir    13_file            \n"\
      ".dir2    04_file  14_file            \n"\
      ".file    04dir    15_file            \n"\
      ".file2   05_file  16_file            \n"\
      "00_file  06_file  17_file            \n"\
      "00dir    07_file  18_file            \n"\
      "01_file  08_file  19_file            \n"\
      "01dir    09_file  attr_file          \n"\
      "02_file  10_file  make_test_file.rb  \n"\
      "02dir    11_file  \n"
    assert_equal true_str, output
  end

  def test_current_dir_list_display_with_option_r
    output = `ruby #{ls_path} -r`
    true_str =
      "make_test_file.rb  12_file  04_file  \n"\
      "attr_file          11_file  03dir    \n"\
      "19_file            10_file  03_file  \n"\
      "18_file            09_file  02dir    \n"\
      "17_file            08_file  02_file  \n"\
      "16_file            07_file  01dir    \n"\
      "15_file            06_file  01_file  \n"\
      "14_file            05_file  00dir    \n"\
      "13_file            04dir    00_file  \n"
    assert_equal true_str, output
  end

  def test_dir_list_display_with_dir_path_and_option_r
    output = `ruby #{ls_path} #{test_data_dir} -r`
    true_str =
      "make_test_file.rb  12_file  04_file  \n"\
      "attr_file          11_file  03dir    \n"\
      "19_file            10_file  03_file  \n"\
      "18_file            09_file  02dir    \n"\
      "17_file            08_file  02_file  \n"\
      "16_file            07_file  01dir    \n"\
      "15_file            06_file  01_file  \n"\
      "14_file            05_file  00dir    \n"\
      "13_file            04dir    00_file  \n"
    assert_equal true_str, output
  end

  def test_dir_list_display_with_multiple_dir_paths_and_option_r
    output = `ruby #{ls_path} 00dir 01dir -r`
    true_str =
      "01dir:\n"\
      "35_file  33_file  31_file  \n"\
      "34_file  32_file  30_file  \n"\
      "\n"\
      "00dir:\n"\
      "25_file  23_file  21_file  \n"\
      "24_file  22_file  20_file  \n"
    assert_equal true_str, output
  end

  def test_dir_list_display_with_multiple_dir_and_file_paths_and_option_r
    output = `ruby #{ls_path} 00dir 01dir 01_file 02_file 03_file 04_file -r;`
    true_str =
      "04_file  02_file  \n"\
      "03_file  01_file  \n"\
      "\n"\
      "01dir:\n"\
      "35_file  33_file  31_file  \n"\
      "34_file  32_file  30_file  \n"\
      "\n"\
      "00dir:\n"\
      "25_file  23_file  21_file  \n"\
      "24_file  22_file  20_file  \n"
    assert_equal true_str, output
  end

  def test_adjust_list_to_display
    files = Dir.glob('*', base: test_data_dir)
    assert_equal '00_file  04dir    13_file            ', adjust_list_to_display(files)[0]
  end

  def test_glob_file_list_with_path
    output = `ruby #{ls_path} 00dir`
    true_str =
      "20_file  22_file  24_file  \n"\
      "21_file  23_file  25_file  \n"
    assert_equal true_str, output
  end

  def test_adjust_list_to_display_when_there_are_3_files
    files = Dir.glob('*', base: "#{test_data_dir}/03dir")
    assert_equal '20_file  21_file  22_file  ', adjust_list_to_display(files)[0]
  end

  def test_adjust_list_to_display_when_there_is_0_file
    files = Dir.glob('*', base: "#{test_data_dir}/04dir/05dir")
    assert_nil adjust_list_to_display(files)[0]
  end

  def test_make_display_list_with_multiple_paths
    output = `ruby #{ls_path} 00dir 01dir`
    true_str =
      "00dir:\n"\
      "20_file  22_file  24_file  \n"\
      "21_file  23_file  25_file  \n"\
      "\n"\
      "01dir:\n"\
      "30_file  32_file  34_file  \n"\
      "31_file  33_file  35_file  \n"
    assert_equal true_str, output
  end

  # ファイルが指定された場合
  def test_make_display_list_with_file_name
    output = `ruby #{ls_path} 01_file`
    true_str = "01_file  \n\n"
    assert_equal true_str, output
  end

  # ファイルとパスが複数指定された場合
  def test_make_display_list_with_file_name_and_paths
    output = `ruby #{ls_path} 01_file 02dir 03_file 04dir`
    true_str =
      "01_file  03_file  \n"\
      "\n"\
      "02dir:\n"\
      "20_file        23_あああ              あ_file          \n"\
      "21_file        24_looooong_name_file  あいうえお_file  \n"\
      "22_あああfile  25_file                \n"\
      "\n"\
      "04dir:\n"\
      "05dir    21_file  \n"\
      "20_file  22_file  \n"
    assert_equal true_str, output
  end

  def test_current_dir_list_display_with_option_l
    output = `ruby #{ls_path} -l`
    true_str =
      "total 24\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 00_file\n"\
      "drwxr-xr-x 2 rira rira 4096 Nov 22 10:03 00dir\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 01_file\n"\
      "drwxr-xr-x 2 rira rira 4096 Nov 22 15:15 01dir\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 02_file\n"\
      "drwxr-xr-x 2 rira rira 4096 Nov 22 16:37 02dir\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 03_file\n"\
      "drwxr-xr-x 2 rira rira 4096 Nov 22 14:37 03dir\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 04_file\n"\
      "drwxr-xr-x 3 rira rira 4096 Nov 22 14:30 04dir\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 05_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 06_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 07_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 08_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 09_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 14:54 10_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 11_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 12_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 13_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 14_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 15_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 16_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 17_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 18_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 22 10:03 19_file\n"\
      "----rw-r-- 1 rira rira    0 Nov 23 09:32 attr_file\n"\
      "----rw-r-- 1 rira rira  233 Nov 22 11:36 make_test_file.rb\n"
    assert_equal true_str, output
  end
end
