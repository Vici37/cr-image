require "digest"
require "spectator"
require "spectator/should"
require "../src/cr-image"

module SpecHelper
  def self.read_sample(name : String) : String
    File.read("lib/pluto_samples/#{name}")
  end

  def self.bit_arr(size : Int32, int : Int)
    BitArray.new(size) { |i| int.bit(size - i - 1) > 0 }
  end
end
