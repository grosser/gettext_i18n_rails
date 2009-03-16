module GettextI18nRails
  #This haml interpreter only extracts translation calls,
  #in an attempt to make haml files readable for gettext
  #  .test{:style=>'hello'}=_('xx') => _('xx')
  # TODO parser does not find correct line number...
  # TODO msgids that contain braces are not supported... (better to have missing translation then wrong translations)
  class HamlTranslationExtractor
    HAML_COMMENT = /(\s*)\-#/
    TRANSLATION = /[^a-z]([snp]?_\([^\(]*?\))/

    def self.parse(text)
      comment_depth = nil
      text.split(/\n/).map do |line|
        result, comment_depth = parse_line(line, comment_depth)
        result
      end
    end

    private

    #returns [result,new_comment_depth]
    def self.parse_line(line,comment_depth)
      return ['',comment_depth] if line_inside_comment_block?(line,comment_depth)
      comment_depth = nil

      if line =~ HAML_COMMENT
        comment_depth = indentation(line)
        return ['',comment_depth]
      end

      return [$1,nil] if line =~ TRANSLATION
      
      ['',comment_depth]
    end

    def self.indentation(line)
      line.length - line.lstrip.length
    end

    #  xxx => false
    #  -# => depth:0
    #    aa =>true
    #  yy => false
    def self.line_inside_comment_block?(line,comment_depth)
      comment_depth and indentation(line) > comment_depth
    end
  end
end