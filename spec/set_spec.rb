require 'spec_helper'

describe Porpoise::Set do
  it "can add multiple members to a set" do
    Porpoise::Set.sadd('set-test0', 'foo', 'bar', 'baz')
    expect(Porpoise::Set.scard('set-test0')).to eql(3)
    expect(Porpoise::Set.smembers('set-test0')).to eql(['foo', 'bar', 'baz'])
  end

  it "can count the members in a set" do
    Porpoise::Set.sadd('set-test1', 'foo', 'bar', 'baz')
    expect(Porpoise::Set.scard('set-test1')).to eql(3)
  end

  it "can create a diff between two sets" do
    Porpoise::Set.sadd('set-test2', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test3', 'bar', 'boo', 'caz')
    expect(Porpoise::Set.sdiff('set-test2', 'set-test3')).to eql(['foo', 'baz'])
  end

  it "can create a diff between two or more sets" do
    Porpoise::Set.sadd('set-test4', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test5', 'bar', 'boo', 'caz')
    Porpoise::Set.sadd('set-test6', 'moo', 'foo', 'raz')
    expect(Porpoise::Set.sdiff('set-test4', 'set-test5', 'set-test6')).to eql(['baz'])
  end

  it "can create a diff between two or more sets and store the result" do
    Porpoise::Set.sadd('set-test7', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test8', 'bar', 'boo', 'caz')
    Porpoise::Set.sadd('set-test9', 'moo', 'foo', 'raz')
    Porpoise::Set.sdiffstore('set-test10', 'set-test7', 'set-test8', 'set-test9')
    expect(Porpoise::Set.smembers('set-test10')).to eql(['baz'])
  end

  it "can check if a set contains a member" do
    Porpoise::Set.sadd('set-test11', 'foo', 'bar', 'baz')
    expect(Porpoise::Set.sismember('set-test11', 'foo')).to eql(1)
    expect(Porpoise::Set.sismember('set-test11', 'raz')).to eql(0)
  end

  it "can return all members of a set" do
    Porpoise::Set.sadd('set-test12', 'foo', 'bar', 'baz')
    expect(Porpoise::Set.smembers('set-test12')).to eql(['foo', 'bar', 'baz'])
  end

  it "can pop a number of members from a set" do
    Porpoise::Set.sadd('set-test13', 'foo', 'bar', 'baz', 'faz', 'boo', 'caz')
    pres = Porpoise::Set.spop('set-test13', 2)
    expect(pres.size).to eql(2)
    expect(Porpoise::Set.scard('set-test13')).to eql(4)
    expect(Porpoise::Set.smembers('set-test13')).not_to include(*pres)
  end

  it "can return a number of random members from a set without changing the set" do
    Porpoise::Set.sadd('set-test14', 'foo', 'bar', 'baz', 'faz', 'boo', 'caz')
    pres = Porpoise::Set.srandmember('set-test14', 4)
    expect(pres.size).to eql(4)
    expect(Porpoise::Set.scard('set-test14')).to eql(6)
    expect(Porpoise::Set.smembers('set-test14')).to include(*pres)
  end

  it "can move a set member from one set to the other" do
    Porpoise::Set.sadd('set-test15', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test16', 'faz', 'boo', 'caz')
    Porpoise::Set.smove('set-test15', 'set-test16', 'bar')
    expect(Porpoise::Set.scard('set-test15')).to eql(2)
    expect(Porpoise::Set.scard('set-test16')).to eql(4)
    expect(Porpoise::Set.smembers('set-test16')).to include('bar')
    expect(Porpoise::Set.smembers('set-test15')).not_to include('bar')
  end

  it "has no duplicate members" do
    Porpoise::Set.sadd('set-test17', 'foo', 'bar', 'baz', 'faz', 'baz', 'foo')
    expect(Porpoise::Set.scard('set-test17')).to eql(4)
  end

  it "can remove multiple members from a set" do
    Porpoise::Set.sadd('set-test18', 'foo', 'bar', 'baz', 'faz', 'boo', 'caz')
    Porpoise::Set.srem('set-test18', 'baz', 'faz')
    expect(Porpoise::Set.scard('set-test18')).to eql(4)
    expect(Porpoise::Set.smembers('set-test18')).not_to include('baz', 'faz')
  end

  it "can union two or more sets" do
    Porpoise::Set.sadd('set-test19', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test20', 'bar', 'boo', 'caz')
    Porpoise::Set.sadd('set-test21', 'moo', 'foo', 'raz')
    expect(Porpoise::Set.sunion('set-test19', 'set-test20', 'set-test21')).to eql(['foo', 'bar', 'baz', 'boo', 'caz', 'moo', 'raz'])
  end

  it "can union two or more sets and store the result" do
    Porpoise::Set.sadd('set-test22', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test23', 'bar', 'boo', 'caz')
    Porpoise::Set.sadd('set-test24', 'moo', 'foo', 'raz')
    expect(Porpoise::Set.sunionstore('set-test25', 'set-test22', 'set-test23', 'set-test24')).to eql(7)
    expect(Porpoise::Set.smembers('set-test25')).to eql(['foo', 'bar', 'baz', 'boo', 'caz', 'moo', 'raz'])
  end

  it "can intersect two or more sets" do
    Porpoise::Set.sadd('set-test26', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test27', 'bar', 'boo', 'foo')
    Porpoise::Set.sadd('set-test28', 'moo', 'foo', 'bar')
    expect(Porpoise::Set.sinter('set-test26', 'set-test27', 'set-test28')).to eql(['foo', 'bar'])
  end

  it "can intersect two or more sets and store the result" do
    Porpoise::Set.sadd('set-test29', 'foo', 'bar', 'baz')
    Porpoise::Set.sadd('set-test30', 'bar', 'boo', 'foo')
    Porpoise::Set.sadd('set-test31', 'moo', 'foo', 'bar')
    expect(Porpoise::Set.sinterstore('set-test32', 'set-test29', 'set-test30', 'set-test31')).to eql(2)
    expect(Porpoise::Set.smembers('set-test32')).to eql(['foo', 'bar'])
  end
end
