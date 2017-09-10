require 'spec_helper'

describe Porpoise do
  it "can store keys in a namespace" do
    Porpoise::with_namespace('test-namespace') { Porpoise::String.set('ns-test0', 'foo') }
    expect(Porpoise::with_namespace('test-namespace') { Porpoise::String.get('ns-test0') }).to eql('foo')
    expect(Porpoise::String.get('ns-test0')).to eql(nil) # outside namespace
  end
end
