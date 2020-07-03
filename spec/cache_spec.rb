require 'spec_helper'

describe ActiveSupport::Cache::PorpoiseStore do
  it "can write within a namespace" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test0' })
    cache.write('foo', 'bar')
    expect(cache.read('foo')).to eql('bar')
    expect(Marshal.load(Porpoise::String.get('porpoise-test0:foo'))).to eql('bar')
  end

  it "can clear the entire cache" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test1' })
    cache.write('foo', 'bar')
    expect(cache.read('foo')).to eql('bar')
    cache.clear
    expect(cache.read('foo')).to eql(nil)
  end

  it "can decrement a cached value" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test2' })
    cache.write('foo', 6)
    decrement_result = cache.decrement('foo', 4)
    expect(decrement_result).to eql(2)
    expect(cache.read('foo')).to eql(2)
  end

  it "can increment a cached value" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test3' })
    cache.write('foo', 6)
    increment_result = cache.increment('foo', 3)
    expect(increment_result).to eql(9)
    expect(cache.read('foo')).to eql(9)
  end

  it "can increment an entry that does not exist (by first initializing to 0)" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test3b' })
    increment_result = cache.increment('foo', 3)
    expect(increment_result).to eql(3)
    expect(cache.read('foo')).to eql(3)
  end

  it "can delete items from cache" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test4' })
    cache.write('foo', 'bar')
    expect(cache.read('foo')).to eql('bar')
    cache.delete('foo')
    expect(cache.read('foo')).to eql(nil)
  end

  it "can delete multiple items from cache with a matcher" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test5' })
    cache.write('foo-a', 'bar')
    cache.write('foo-b', 'baz')
    cache.write('foo-c', 'bax')
    expect(cache.read('foo-a')).to eql('bar')
    expect(cache.read('foo-c')).to eql('bax')
    cache.delete_matched('foo-*')
    expect(cache.read('foo-a')).to eql(nil)
    expect(cache.read('foo-c')).to eql(nil)
  end

  it "can check if an item in cache exists" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test6' })
    cache.write('foo', 'bar')
    expect(cache.exists?('foo')).to eql(true)
    expect(cache.exists?('bar')).to eql(false)
  end

  it "can fetch an item from cache" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test7' })
    cache.write('foo', 'bar')
    expect(cache.fetch('foo')).to eql('bar')
  end

  it "can fetch an item from cache with a block" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test8' })
    expect(cache.fetch('faz') { 'baz' }).to eql('baz')
    expect(cache.read('faz')).to eql('baz')
  end

  it "can fetch multiple items from cache" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test7' })
    cache.write('foo', 'bar')
    cache.write('bar', 'foo')
    expect(cache.fetch_multi('foo', 'bar', 'baz')).to eql({ 'foo' => 'bar', 'bar' => 'foo', 'baz' => nil })
  end

  it "can fetch multiple items from cache with a block" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test8' })
    cache.write('foo', 'bar')
    cache.write('bar', 'foo')
    expect(cache.fetch_multi('foo', 'bar', 'baz') { |key| "#{key}foo#{key}" }).to eql({ 'foo' => 'bar', 'bar' => 'foo', 'baz' => 'bazfoobaz' })
    expect(cache.read('baz')).to eql('bazfoobaz')
  end

  it "can cleanup expired items" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test8' })
    (1...330).each do |i|
      cache.write("foo#{i}", "bar#{i}", { expires_in: 1 } )
    end

    cache.write("foo_not_expiring_1", "bar_not_expiring_1", { expires_in: 1440 } )
    cache.write("foo_not_expiring_2", "bar_not_expiring_2", { expires_in: 1440 } )

    expect(cache.read('foo1')).to eql('bar1')
    expect(cache.read('foo100')).to eql('bar100')
    expect(cache.read('foo200')).to eql('bar200')
    expect(cache.read('foo300')).to eql('bar300')
    expect(cache.read('foo329')).to eql('bar329')

    expect(cache.read('foo_not_expiring_1')).to eql('bar_not_expiring_1')
    expect(cache.read('foo_not_expiring_2')).to eql('bar_not_expiring_2')

    sleep 1
    total_deleted_items_count = cache.cleanup

    expect(total_deleted_items_count).to eql(329)
    expect(cache.read('foo1')).to eql(nil)
    expect(cache.read('foo100')).to eql(nil)
    expect(cache.read('foo200')).to eql(nil)
    expect(cache.read('foo300')).to eql(nil)
    expect(cache.read('foo329')).to eql(nil)

    expect(cache.read('foo_not_expiring_1')).to eql('bar_not_expiring_1')
    expect(cache.read('foo_not_expiring_2')).to eql('bar_not_expiring_2')
  end

  it 'uses the database connection of Porpoise::KeyValueObject when cleaning expired items' do
    expect(Porpoise::KeyValueObject).to receive(:connection).and_call_original

    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test8' })
    cache.cleanup
  end

  it "can fetch an item from cache with a block and set an expiration date" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test9' })
    expect(cache.fetch('faz', expires_in: 1.hour) { 'baz' }).to eql('baz')
    sleep 0.1
    expect(Porpoise::Key.ttl('faz')).to be < 3600
  end

  it "can fetch an item and set a new value once expired" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test10' })
    expect(cache.fetch('faz', expires_in: 1 ) { 'baz' }).to eql('baz')
    sleep 1.1
    expect(cache.fetch('faz', expires_in: 1 ) { 'raz' }).to eql('raz')
  end

  it "should remove old items from the short term cache when exceeding the cache limit" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test11' })
    t = ActiveSupport::Cache::PorpoiseStore::SHORT_LIFE_CACHE_SIZE + 10
    t.times.each_with_index do |idx|
      cache.write("foo-#{idx}", "bar")
    end
    expect(cache.slc.keys.size).to eql(ActiveSupport::Cache::PorpoiseStore::SHORT_LIFE_CACHE_SIZE)
  end

  it "should remove dead items from the short term cache" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test12' })
    cache.write("foo", "bar")
    sleep (ActiveSupport::Cache::PorpoiseStore::SHORT_LIFE_CACHE_TIME + 1)
    tm = Time.now.to_i
    cache.read("foo")
    expect(cache.slt.values.first).to be >= tm
  end

  it "should not raise when deleting non-existing items" do
    cache = ActiveSupport::Cache::PorpoiseStore.new({ namespace: 'porpoise-test13' })
    expect { cache.delete('foo') }.to_not raise_error
  end
end
