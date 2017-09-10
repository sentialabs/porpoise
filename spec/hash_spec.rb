require 'spec_helper'

describe Porpoise::Hash do
  it "deletes a field" do
    Porpoise::Hash.hset('hash-test0', 'foo', 'bar')
    expect(Porpoise::Hash.hlen('hash-test0')).to eql(1)
    expect(Porpoise::Hash.hdel('hash-test0', 'foo')).to eql(1)
    expect(Porpoise::Hash.hlen('hash-test0')).to eql(0)
  end

  it "deletes multiple fields" do
    Porpoise::Hash.hset('hash-test1', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test1', 'bar', 'foo')
    expect(Porpoise::Hash.hlen('hash-test1')).to eql(2)
    expect(Porpoise::Hash.hdel('hash-test1', 'foo', 'bar')).to eql(2)
    expect(Porpoise::Hash.hlen('hash-test1')).to eql(0)
  end

  it "can check if a field exists" do
    Porpoise::Hash.hset('hash-test2', 'foo', 'bar')
    expect(Porpoise::Hash.hexists('hash-test2', 'foo')).to eql(1)
  end

  it "can check if a field does not exist" do
    Porpoise::Hash.hset('hash-test3', 'foo', 'bar')
    expect(Porpoise::Hash.hexists('hash-test3', 'bar')).to eql(0)
  end

  it "can retrieve a field" do
    Porpoise::Hash.hset('hash-test4', 'foo', 'bar')
    expect(Porpoise::Hash.hget('hash-test4', 'foo')).to eql('bar')
  end

  it "can retrieve a full key" do
    Porpoise::Hash.hset('hash-test5', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test5', 'bar', 'foo')
    expect(Porpoise::Hash.hgetall('hash-test5')).to eql({ 'foo' => 'bar', 'bar' => 'foo' })
  end

  it "can increment by integer" do
    Porpoise::Hash.hset('hash-test6', 'foo', 0)
    Porpoise::Hash.hincrby('hash-test6', 'foo', 2)
    expect(Porpoise::Hash.hget('hash-test6', 'foo')).to eql(2)
  end

  it "can increment by float" do
    Porpoise::Hash.hset('hash-test7', 'foo', 0.2)
    Porpoise::Hash.hincrbyfloat('hash-test7', 'foo', 3.6)
    expect(Porpoise::Hash.hget('hash-test7', 'foo')).to eql(3.8)
  end

  it "can retrieve all fields" do
    Porpoise::Hash.hset('hash-test8', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test8', 'bar', 'foo')
    expect(Porpoise::Hash.hkeys('hash-test8')).to eql(['foo', 'bar'])
  end

  it "can count all fields" do
    Porpoise::Hash.hset('hash-test9', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test9', 'bar', 'foo')
    expect(Porpoise::Hash.hlen('hash-test9')).to eql(2)
  end

  it "can retrieve multiple fields" do
    Porpoise::Hash.hset('hash-test10', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test10', 'bar', 'foo')
    expect(Porpoise::Hash.hmget('hash-test10', 'foo', 'bar', 'baz')).to eql(['bar', 'foo', nil])
  end

  it "can set multiple fields" do
    Porpoise::Hash.hmset('hash-test11', 'foo', 'bar', 'bar', 'foo', 'baz', 'doo')
    expect(Porpoise::Hash.hgetall('hash-test11')).to eql({ 'foo' => 'bar', 'bar' => 'foo', 'baz' => 'doo' })
  end

  it "can set a single field" do
    Porpoise::Hash.hset('hash-test12', 'foo', 'bar')
    expect(Porpoise::Hash.hget('hash-test12', 'foo')).to eql('bar')
  end

  it "can set a single field only if not already set" do
    Porpoise::Hash.hset('hash-test13', 'foo', 'bar')
    Porpoise::Hash.hsetnx('hash-test13', 'foo', 'baz')
    expect(Porpoise::Hash.hget('hash-test13', 'foo')).to eql('bar')
  end

  it "can retrieve the length of a field value" do
    Porpoise::Hash.hset('hash-test14', 'foo', 'bar')
    expect(Porpoise::Hash.hstrlen('hash-test14', 'foo')).to eql(3)
  end

  it "can retrieve all values of a key" do
    Porpoise::Hash.hset('hash-test15', 'foo', 'bar')
    Porpoise::Hash.hset('hash-test15', 'bar', 'foo')
    expect(Porpoise::Hash.hvals('hash-test15')).to eql(['bar', 'foo'])
  end
end
