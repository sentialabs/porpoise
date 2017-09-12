require 'spec_helper'

describe Porpoise::String do
  it "can append to an existing value" do
    Porpoise::String.set('string-test0', 'foo')
    Porpoise::String.append('string-test0', 'bar')
    expect(Porpoise::String.get('string-test0')).to eql('foobar')
  end

  it "can decrement an existing value by 1" do
    Porpoise::String.set('string-test1', '4')
    Porpoise::String.decr('string-test1')
    expect(Porpoise::String.get('string-test1')).to eql('3')
  end

  it "can decrement an existing value by a chosen number" do
    Porpoise::String.set('string-test2', '4')
    Porpoise::String.decrby('string-test2', 2)
    expect(Porpoise::String.get('string-test2')).to eql('2')
  end

  it "can retrieve a stored value" do
    Porpoise::String.set('string-test3', 'foo')
    expect(Porpoise::String.get('string-test3')).to eql('foo')
  end

  it "can get a range from a stored value" do
    Porpoise::String.set('string-test4', 'foobar')
    expect(Porpoise::String.getrange('string-test4', 2, 5)).to eql('obar')
  end

  it "can set a new value, returning the old value" do
    Porpoise::String.set('string-test5', 'foo')
    expect(Porpoise::String.getset('string-test5', 'bar')).to eql('foo')
    expect(Porpoise::String.get('string-test5')).to eql('bar')
  end

  it "can increment an existing value by 1" do
    Porpoise::String.set('string-test6', '4')
    Porpoise::String.incr('string-test6')
    expect(Porpoise::String.get('string-test6')).to eql('5')
  end

  it "can increment an existing value by a chosen number" do
    Porpoise::String.set('string-test7', '4')
    Porpoise::String.incrby('string-test7', 2)
    expect(Porpoise::String.get('string-test7')).to eql('6')
  end

  it "can retrieve multiple keys" do
    Porpoise::String.set('string-test8', 'foo')
    Porpoise::String.set('string-test9', 'bar')
    Porpoise::String.set('string-test10', 'baz')
    expect(Porpoise::String.mget('string-test8', 'string-test9', 'string-test10', 'string-test100')).to eql(['foo', 'bar', 'baz', nil])
  end

  it "can set multiple keys" do
    Porpoise::String.mset('string-test11', 'foo', 'string-test12', 'bar', 'string-test13', 'baz', 'string-test14', 'faz')
    expect(Porpoise::String.mget('string-test11', 'string-test12', 'string-test13', 'string-test14')).to eql(['foo', 'bar', 'baz', 'faz'])
  end

  it "can set an expiration time" do
    Porpoise::String.setex('string-test15', 3600, 'foo')
    expect(Porpoise::String.get('string-test15')).to eql('foo')
    sleep 0.1
    expect(Porpoise::Key.ttl('string-test15')).to be < 3600
  end

  it "can return the length of a string" do
    Porpoise::String.set('string-test16', 'foo')
    expect(Porpoise::String.strlen('string-test16')).to eql(3)
  end

  it "can set a new value" do
    Porpoise::String.set('string-test17', 'foo')
    expect(Porpoise::String.get('string-test17')).to eql('foo')
  end

  it "can set a new value with an expiration time in seconds" do
    Porpoise::String.set('string-test18', 'foo', 3600)
    expect(Porpoise::String.get('string-test18')).to eql('foo')
    sleep 0.1
    expect(Porpoise::Key.ttl('string-test18')).to be < 3600
  end

  it "can set a new value with an expiration time in miliseconds" do
    Porpoise::String.set('string-test19', 'foo', nil, 5000)
    expect(Porpoise::String.get('string-test19')).to eql('foo')
    sleep 0.1
    expect(Porpoise::Key.ttl('string-test19')).to be < 5
  end

  it "can try setting a new value, but only if the key does not already exists" do
    Porpoise::String.set('string-test20', 'foo')
    expect(Porpoise::String.get('string-test20')).to eql('foo')
    Porpoise::String.set('string-test20', 'bar', nil, nil, 'NX')
    expect(Porpoise::String.get('string-test20')).to eql('foo')
  end

  it "can try setting a new value, but only if the key already exists" do
    Porpoise::String.set('string-test21', 'foo')
    expect(Porpoise::String.get('string-test21')).to eql('foo')
    Porpoise::String.set('string-test21', 'bar', nil, nil, 'XX')
    expect(Porpoise::String.get('string-test21')).to eql('bar')
  end

  it "can overwrite an expired item" do
    Porpoise::String.set('string-test22', 'foo', 3)
    expect(Porpoise::String.get('string-test22')).to eql('foo')
    sleep 4
    Porpoise::String.set('string-test22', 'bar')
    expect(Porpoise::String.get('string-test21')).to eql('bar')
  end
end
