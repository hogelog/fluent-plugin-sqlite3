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

    values = [
        [1, 10, "hello"],
        [2, 20, "hi!"],
        [3, 30, "too bad"],
    ]

    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    values.each do|value|
      id, number, message = value
      $driver.emit({"number"=>number, "message"=>message}, time)
    end
    $driver.run

    SQLite3::Database.new($dbname){|db|
      values.each do|value|
        id, number, message = value
        db.execute("SELECT * FROM log WHERE id = ?;", id){|row|
          assert_equal row[0], id
          assert_equal row[1], "test"
          assert_equal row[3], number
          assert_equal row[4], message
        }
      end
    }
  end
end
