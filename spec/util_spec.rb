require 'spec_helper'

describe Porpoise::Util do
  it "can ping the cachestore to check if all appears to be good" do
    expect(Porpoise::Util.ping).to eql(true)
  end

  it "checks datatypes" do
    Porpoise::Hash.hset('check-test0', 'foo', 'bar')
    o = Porpoise::KeyValueObject.where(key: 'check-test0').first
    o.update_column(:data_type, 'String')
    expect { Porpoise::Hash.hget('check-test0', 'foo') }.to raise_error(Porpoise::TypeMismatch)
  end

  it "can raise an error on non-existing keys" do
    expect { Porpoise::Set.smove('check-test1', 'check-test2', 'non-existing-member') }.to raise_error(Porpoise::KeyNotFound)
  end
end
