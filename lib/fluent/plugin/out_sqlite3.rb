class Fluent::Sqlite3Output < Fluent::BufferedOutput
  Fluent::Plugin.register_output('sqlite3', self)

  include Fluent::SetTimeKeyMixin
  config_set_default :include_tag_key, true

  include Fluent::SetTagKeyMixin
  config_set_default :include_time_key, true

  config_param :database, :string
  config_param :table, :string
  config_param :columns, :string

  def initialize
    super
    require 'sqlite3'
  end

  def configure(conf)
    super

    @columns = "tag VARCHAR(20),time DATETIME,#@columns"
    columns = @columns.split(",")
    keys = columns.map{|column| column.split(" ").first}
    @sql = "INSERT INTO #@table (#{keys.join(",")}) VALUES (#{keys.map{"?"}.join(",")});"
    SQLite3::Database.new(@database){|client|
      unless has_table?(client, @table)
        sql = "CREATE TABLE #@table (id INTEGER PRIMARY KEY AUTOINCREMENT,#@columns);"
        client.execute(sql)
      end
    }

    @format_proc = Proc.new{|tag, time, record|
      keys.map{|key| record[key]}
    }
  end

  def has_table?(client, table)
    client.execute('SELECT COUNT(tbl_name) FROM sqlite_master WHERE tbl_name=?;', table) do|row|
      return row.first == 1
    end
    return false
  end

  def format(tag, time, record)
    [tag, time, @format_proc.call(tag, time, record)].to_msgpack
  end

  def write(chunk)
    SQLite3::Database.new(@database){|client|
      chunk.msgpack_each do|tag, time, data|
        client.execute(@sql, data)
      end
    }
  end

  def start
    super
  end

  def shutdown
    super
  end
end
