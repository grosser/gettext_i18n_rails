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
        next if model.abstract_class
        table_name = model.table_name
        next if ignored?(table_name,options[:ignore_tables])
        model.columns.each do |column|
          found[model] += [column.name] unless ignored?(column.name,options[:ignore_columns])
        end
        found[model].sort!
      end

      found
    end

    def models
      if Rails::VERSION::MAJOR > 2
        Rails.application.eager_load! # make sure that all models are loaded so that direct_descendants works
        ::ActiveRecord::Base.direct_descendants
      else
        ::ActiveRecord::Base.connection.tables.map {|t| table_name_to_namespaced_model(t) }
      end.compact.sort {|c1, c2| c1.name <=> c2.name}
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
      end

      return constant.is_a?(Class) ? constant : nil
    end
  end
end
