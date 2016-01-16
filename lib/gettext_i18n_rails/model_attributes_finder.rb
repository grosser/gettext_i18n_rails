require 'rails/version'
require 'rails' if Rails::VERSION::MAJOR > 2

module GettextI18nRails
  #write all found models/columns to a file where GetTexts ruby parser can find them
  def store_model_attributes(options)
    file = options[:to] || 'locale/model_attributes.rb'
    begin
      File.open(file,'w') do |f|
        f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
        ModelAttributesFinder.new.find(options).each do |model,column_names|
          f.puts("_('#{model.humanize_class_name}')")

          #all columns namespaced under the model
          column_names.each do |attribute|
            translation = model.gettext_translation_for_attribute_name(attribute)
            f.puts("_('#{translation}')")
          end
        end
        f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
      end
    rescue
      puts "[Error] Attribute extraction failed. Removing incomplete file (#{file})"
      File.delete(file)
      raise
    end
  end
  module_function :store_model_attributes

  class ModelAttributesFinder
    # options:
    #   :ignore_tables => ['cars',/_settings$/,...]
    #   :ignore_columns => ['id',/_id$/,...]
    # current connection ---> {'cars'=>['model_name','type'],...}
    def find(options)
      found = ActiveSupport::OrderedHash.new([])
      models.each do |model|
        attributes = model_attributes(model, options[:ignore_tables], options[:ignore_columns])
        found[model] = attributes.sort if attributes.any?
      end
      found
    end

    def initialize
      connection = ::ActiveRecord::Base.connection
      @existing_tables = (Rails::VERSION::MAJOR >= 5 ? connection.data_sources : connection.tables)
    end

    # Rails < 3.0 doesn't have DescendantsTracker.
    # Instead of iterating over ObjectSpace (slow) the decision was made NOT to support
    # class hierarchies with abstract base classes in Rails 2.x
    def model_attributes(model, ignored_tables, ignored_cols)
      return [] if model.abstract_class? && Rails::VERSION::MAJOR < 3

      if model.abstract_class?
        model.direct_descendants.reject {|m| ignored?(m.table_name, ignored_tables)}.inject([]) do |attrs, m|
          attrs.push(model_attributes(m, ignored_tables, ignored_cols)).flatten.uniq
        end
      elsif !ignored?(model.table_name, ignored_tables) && @existing_tables.include?(model.table_name)
        model.columns.reject { |c| ignored?(c.name, ignored_cols) }.collect { |c| c.name }
      else
        []
      end
    end

    def models
      if Rails::VERSION::MAJOR >= 3
        Rails.application.eager_load! # make sure that all models are loaded so that direct_descendants works
        descendants = ::ActiveRecord::Base.direct_descendants

        # In rails 5+ user models are supposed to inherit from ApplicationRecord
        if defined?(::ApplicationRecord)
          descendants += ApplicationRecord.direct_descendants
          descendants.delete ApplicationRecord
        end

        descendants
      else
        ::ActiveRecord::Base.connection.tables \
          .map { |t| table_name_to_namespaced_model(t) } \
          .compact \
          .collect { |c| c.superclass.abstract_class? ? c.superclass : c }
      end.uniq.sort_by(&:name)
    end

    def ignored?(name,patterns)
      return false unless patterns
      patterns.detect{|p|p.to_s==name.to_s or (p.is_a?(Regexp) and name=~p)}
    end

    private
    # Tries to find the model class corresponding to specified table name.
    # Takes into account that the model can be defined in a namespace.
    # Searches only up to one level deep - won't find models nested in two
    # or more modules.
    #
    # Note that if we allow namespaces, the conversion can be ambiguous, i.e.
    # if the table is named "aa_bb_cc" and AaBbCc, Aa::BbCc and AaBb::Cc are
    # all defined there's no absolute rule that tells us which one to use.
    # This method prefers the less nested one and, if there are two at
    # the same level, the one with shorter module name.
    def table_name_to_namespaced_model(table_name)
      # First assume that there are no namespaces
      model = to_class(table_name.singularize.camelcase)
      return model if model != nil

      # If you were wrong, assume that the model is in a namespace.
      # Iterate over the underscores and try to substitute each of them
      # for a slash that camelcase() replaces with the scope operator (::).
      underscore_position = table_name.index('_')
      while underscore_position != nil
        namespaced_table_name = table_name.dup
        namespaced_table_name[underscore_position] = '/'
        model = to_class(namespaced_table_name.singularize.camelcase)
        return model if model != nil

        underscore_position = table_name.index('_', underscore_position + 1)
      end

      # The model either is not defined or is buried more than one level
      # deep in a module hierarchy
      return nil
    end

    # Checks if there is a class of specified name and if so, returns
    # the class object. Otherwise returns nil.
    def to_class(name)
      # I wanted to use Module.const_defined?() here to avoid relying
      # on exceptions for normal program flow but it's of no use.
      # If class autoloading is enabled, the constant may be undefined
      # but turn out to be present when we actually try to use it.
      begin
        constant = name.constantize
      rescue NameError
        return nil
      rescue LoadError => e
        $stderr.puts "failed to load '#{name}', ignoring (#{e.class}: #{e.message})"
        return nil
      end

      return constant.is_a?(Class) ? constant : nil
    end
  end
end
