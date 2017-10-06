require 'spec_helper'

describe "Performance Test" do
  it "can insert 200 string objects in 200ms" do
    expect {
      200.times.each_with_index do |idx|
        Porpoise::String.set("perf-string-test#{idx}", 'bar')
      end
    }.to perform_under(200).ms
  end

  it "can insert 100 hashes in 300ms" do
    expect {
      100.times.each_with_index do |idx|
        Porpoise::Hash.hset("perf-hash-test#{idx}", 'bar', 'foo')
        Porpoise::Hash.hset("perf-hash-test#{idx}", 'foo', 'bar')
      end
    }.to perform_under(300).ms
  end

  it "can insert 100 sets in 150ms" do
    expect {
      100.times.each_with_index do |idx|
        Porpoise::Set.sadd("perf-set-test#{idx}", 'bar', 'foo', 'baz', 'faz')
      end
    }.to perform_under(150).ms
  end
end
