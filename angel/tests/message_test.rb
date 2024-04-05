# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../message.rb'

class MessageTest < Minitest::Test
  def test_get_header_data_happy_path 
    assert_equal 'meow', GridTP::Message.get_header_data('#!/meow')
  end

  def test_get_header_doesnt_start_with_prepend
    assert_raises(GridTP::Message::MessageParseError) { GridTP::Message.get_header_data('owo') }
  end

  def test_verify_version_happy_path
    assert GridTP::Message.verify_version('gridtp/1.0.0')
  end

  def test_verify_version_incorrect
    refute GridTP::Message.verify_version('owo')
  end
end

class RequestTest < Minitest::Test
end
