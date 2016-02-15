require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |k, v| "#{k} = ?" }.join(" AND ")
    attr_values = params.values

    row = DBConnection.execute(<<-SQL, *attr_values)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    row.map { |options| self.new(options) }
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
