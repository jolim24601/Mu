require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    return "humans" if class_name == "Human"
    class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.camelcase,
      foreign_key: (name + "ID").underscore.to_sym,
      primary_key: :id
    }
    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.singularize.camelcase,
      foreign_key: (self_class_name + "ID").underscore.to_sym,
      primary_key: :id
    }
    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  def assoc_options
    @options ||= {}
  end

  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name.to_s, options)
    # returns the association
    define_method("#{name}") do
      options = self.class.assoc_options[name]
      foreign_key = send(options.foreign_key)
      result = options.model_class.where(id: foreign_key)
      result.first
    end
  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name.to_s, self.name, options)

    define_method("#{name}") do
      options = self.class.assoc_options[name]
      params = { options.foreign_key.to_s => id }
      options.model_class.where(params)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method("#{name}") do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_key = send(through_options.foreign_key)

      result = DBConnection.execute(<<-SQL, key: through_key)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
          ON #{through_options.table_name}.#{source_options.foreign_key}
            AND #{source_options.table_name}.id
        WHERE
          #{through_options.table_name}.id = :key
      SQL

      source_options.model_class.new(result.first)
    end
  end

  # could be defined by another has_many defined in `self`
  # "through" could be a join table made up of two foreign keys
  def has_many_through(name, through_name, source_name)
    define_method("#{name}") do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL, id: self.id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        INNER JOIN
          #{through_options.table_name}
          ON #{source_options.table_name}.#{source_options.foreign_key}
            = #{through_options.table_name}.id
        WHERE
          #{through_options.table_name}
          .#{through_options.foreign_key} = :id
      SQL

      results.map do |result|
        source_options.model_class.new(result)
      end
    end
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
