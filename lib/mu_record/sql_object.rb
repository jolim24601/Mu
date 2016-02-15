require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||=
    DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
      .first
      .map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(rows)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL

    return row.first if row.first.nil?
    self.new(row.first)
  end

  def initialize(params = {})
    params.each do |key, value|
      attr_name = key.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attr_values = self.class.columns.map { |col| send(col) }
  end

  # doesn't yet account for the id column...
  def insert
    col_names = self.class.columns.join(", ")
    question_marks = self.class.columns.map { |col| "?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    question_marks = self.class.columns[1..-1]
      .map { |col| "#{col} = ?" }
      .join(", ")

    attr_values = attribute_values.rotate

    DBConnection.execute(<<-SQL, *attribute_values.rotate)
      UPDATE
        #{self.class.table_name}
      SET
        #{question_marks}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
