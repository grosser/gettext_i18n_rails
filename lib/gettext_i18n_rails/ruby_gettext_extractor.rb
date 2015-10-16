gem 'ruby_parser', '>= 3.7.1' # sync with gemspec
require 'ruby_parser'

gem 'sexp_processor'
require 'sexp_processor'

module RubyGettextExtractor
  extend self

  def parse(file, targets = [])  # :nodoc:
    parse_string(File.read(file), targets, file)
  end

  def parse_string(content, targets = [], file)
    syntax_tree = RubyParser.for_current_ruby.parse(content, file)

    processor = Extractor.new(targets)
    processor.require_empty = false
    processor.process(syntax_tree)

    processor.results
  end

  class Extractor < SexpProcessor
    attr_reader :results

    def initialize(targets)
      @targets = {}
      @results = []

      targets.each do |a|
        k, _v = a
        # things go wrong if k already exists, but this
        # should not happen (according to the gettext doc)
        @targets[k] = a
        @results << a
      end

      super()
    end

    def extract_string(node)
      case node.first
      when :str
        node.last
      when :call
        type, recv, meth, args = node
        # node has to be in form of "string" + "other_string"
        return nil unless recv && meth == :+

        first_part  = extract_string(recv)
        second_part = extract_string(args)

        first_part && second_part ? first_part.to_s + second_part.to_s : nil
      else
        nil
      end
    end

    def extract_key_singular(args, separator)
      key = extract_string(args) if args.size == 2 || args.size == 4

      return nil unless key
      key.gsub("\n", '\n').gsub("\t", '\t').gsub("\0", '\0')
    end

    def extract_key_plural(args, separator)
      # this could be n_("aaa", "aaa plural", @retireitems.length)
      # s(s(:str, "aaa"),
      #   s(:str, "aaa plural"),
      #   s(:call, s(:ivar, :@retireitems), :length))
      # all strings arguments are extracted and joined with \004 or \000
      arguments = args[0..(-2)]

      res = []
      arguments.each do |a|
        next unless a.kind_of? Sexp
        str = extract_string(a)
        res << str if str
      end

      key = res.empty? ? nil : res.join(separator)

      return nil unless key
      key.gsub("\n", '\n').gsub("\t", '\t').gsub("\0", '\0')
    end

    def store_key(key, args)
      if key
        res = @targets[key]

        unless res
          res = [key]
          @results << res
          @targets[key] = res
        end

        res << "#{args.file}:#{args.line}"
      end
    end

    def gettext_simple_call(args)
      # args comes in 2 forms:
      #   s(s(:str, "Button Group Order:"))
      #   s(:str, "Button Group Order:")
      # normalizing:
      args = args.first if Sexp === args.sexp_type

      key  = extract_key_singular(args, "\004")
      store_key(key, args)
    end

    def gettext_plural_call(args)
      key = extract_key_plural(args, "\000")
      store_key(key, args)
    end

    def process_call exp
      _call = exp.shift
      _recv = process exp.shift
      meth  = exp.shift

      case meth
      when :_, :p_, :N_, :pgettext, :s_
        gettext_simple_call(exp)
      when :n_
        gettext_plural_call(exp)
      end

      until exp.empty? do
        process(exp.shift)
      end

      s()
    end
  end
end
