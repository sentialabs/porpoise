require 'spec_helper'

describe Porpoise::Key do
  it "can delete multiple key" do
    Porpoise::String.set('key-test1', 'foo')
    Porpoise::String.set('key-test2', 'bar')
    expect(Porpoise::String.get('key-test1')).to eql('foo')
    expect(Porpoise::String.get('key-test2')).to eql('bar')
    Porpoise::Key.del('key-test1', 'key-test2')
    expect(Porpoise::String.get('key-test1')).to eql(nil)
    expect(Porpoise::String.get('key-test2')).to eql(nil)
  end

  it "can check whether a key exists" do
    Porpoise::String.set('key-test3', 'foo')
    Porpoise::String.set('key-test4', 'bar')
    expect(Porpoise::Key.exists('key-test3', 'key-test4', 'key-test5')).to eql(2)
  end

  it "can expire a key" do
    Porpoise::String.set('key-test5', 'foo', 3600)
    sleep 0.1
    expect(Porpoise::Key.ttl('key-test5')).to be < 3600
    expect(Porpoise::Key.ttl('key-test5')).to be > 3500
    Porpoise::Key.expire('key-test5', 0)
    expect(Porpoise::Key.ttl('key-test5')).to be <= 0
  end

  it "can rename a key" do
    Porpoise::String.set('key-test6', 'foo')
    Porpoise::Hash.hset('key-test7', 'bar', 'faz')
    Porpoise::Key.rename('key-test6', 'key-test7')
    expect(Porpoise::String.get('key-test7')).to eql('foo')
    expect(Porpoise::String.get('key-test6')).to eql(nil)
  end

  it "can return the type of a key" do
    Porpoise::String.set('key-test8', 'foo')
    expect(Porpoise::Key.type('key-test8')).to eql("String")
  end

  it "can dump a key" do
    Porpoise::String.set('key-test9', 'foo')
    expect(Porpoise::Key.dump('key-test9')).to eql(Marshal.dump('foo'))
  end

  it "can return the ttl of a key" do
    Porpoise::String.set('key-test10', 'foo', 3600)
    sleep 0.1
    expect(Porpoise::Key.ttl('key-test10')).to be < 3600
  end

  it "can persist a key with a ttl" do
    Porpoise::String.set('key-test11', 'foo', 3600)
    sleep 0.1
    expect(Porpoise::Key.ttl('key-test11')).to be < 3600
    Porpoise::Key.persist('key-test11')
    expect(Porpoise::Key.ttl('key-test11')).to eql(-1)
  end

  it "can delete keys by matcher" do
    Porpoise::String.set('key-test1', 'foo')
    Porpoise::String.set('key-test2', 'bar')
    expect(Porpoise::String.get('key-test1')).to eql('foo')
    expect(Porpoise::String.get('key-test2')).to eql('bar')
    Porpoise::Key.del_matched('key-test*')
    expect(Porpoise::String.get('key-test1')).to eql(nil)
    expect(Porpoise::String.get('key-test2')).to eql(nil)
  end

  it "can find keys" do
    Porpoise::String.set('key-test-findera-0', 'foo', 3600)
    Porpoise::String.set('key-test-findera-1', 'foo', 3600)
    Porpoise::String.set('key-test-findera-2', 'foo', 3600)

    Porpoise::String.set('key-test-finderb-0', 'foo', 3600)
    Porpoise::String.set('key-test-finderb-1', 'foo', 3600)
    Porpoise::String.set('key-test-finderb-2', 'foo', 3600)

    expect(Porpoise::Key.keys("key-test-finderb-*")).to eql(['key-test-finderb-0', 'key-test-finderb-1', 'key-test-finderb-2'])
    expect(Porpoise::Key.keys("key-test-finder*")).to eql(['key-test-findera-0', 'key-test-findera-1', 'key-test-findera-2', 'key-test-finderb-0', 'key-test-finderb-1', 'key-test-finderb-2'])
    expect(Porpoise::Key.keys("key-test-finderb-1")).to eql(['key-test-finderb-1'])
  end
end
