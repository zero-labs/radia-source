#!/usr/bin/ruby


require 'rubygems'
require 'thread'
require 'eventmachine'


dir = File.dirname(File.expand_path(__FILE__))

require File.join(dir, '../config')
require File.join(dir, '../asset-manager')


EventMachine::run do
        am = PlayoutScheduler::AssetManager.new
        EventMachine::defer { 
            puts "#{Time.now} - am(#{Thread.current}) - #{s}\n"}
        30.times do |x|
            am.request(x)
        end
end
