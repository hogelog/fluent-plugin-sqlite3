require 'helper'
require 'sqlite3'

class Sqlite3OutputTest < Test::Unit::TestCase

  def create_driver(conf = CONFIG, tag='test')
    d = Fluent::Test::BufferedOutputTestDriver.new(Fluent::Sqlite3Output, tag).configure(conf)
    d
  end

  def setup
    Fluent::Test.setup
    require "fluent/plugin/out_sqlite3"

    $dbname = "test.db"
    if File.exist? $dbname then
      File.unlink $dbname
    end
    $db = SQLite3::Database.new $dbname
    $driver = create_driver
    $config = $driver.config
  end

  def teardown
    $db.close
  end

  CONFIG = %[
    database test.db
    table log
    columns number INT, message VARCHAR(255)
  ]
  def test_emit
    $driver

    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    $driver.emit({"number"=>10, "message"=>"hello"}, time)
    $driver.emit({"number"=>20, "message"=>"hi!"}, time)

    $driver.run
  end
end
