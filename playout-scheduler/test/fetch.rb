#!/usr/bin/ruby


require 'rubygems'
require 'eventmachine'


dir = File.dirname(File.expand_path(__FILE__))

require File.join(dir, '../config')
require File.join(dir, '../playout_middleware')

bcs = PlayoutMiddleware::fetch
bc = nil
bcs.each do |x| 
    if x.attributes["type"] != "gap" then
        bc = x
        break
    end
end

p bc

