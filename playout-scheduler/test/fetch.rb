#!/usr/bin/ruby


require 'rubygems'
require 'eventmachine'
require 'test/unit'

dir = File.dirname(File.expand_path(__FILE__))

require File.join(dir, '../config')
require File.join(dir, '../playout_middleware')
#require File.join(dir, '../scheduler.rb')

class TestMiddleware < Test::Unit::TestCase

    def test_fetch
        PlayoutMiddleware::fetch.each do |bc| 
            validate_broadcast bc
        end
    end

    protected
    def validate_broadcast bc
            assert_instance_of(PlayoutMiddleware::Broadcast, bc)
            assert(PlayoutMiddleware::Broadcast.is_valid_broadcast(bc))
    end
end

