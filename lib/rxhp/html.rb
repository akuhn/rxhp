require 'rxhp/data/html/attributes'
require 'rxhp/data/html/tags'
require 'rxhp/html_fragment'

module Rxhp
  # Namespace for all HTML-related classes and methods.
  #
  # Most of RXhp is for generic trees; everything that is HTML or XML
  # specific is defined here, or in {HtmlElement} and its subclasses.
  module Html
    def self.escape text
      text.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;')
    end
  end
end

Rxhp::Html::TAGS.each do |tag, data|
  if data[:require]
    require data[:require]
  else
    data = {
      :is_a => Rxhp::HtmlElement,
    }.merge(data)

    klass_name = tag.to_s.dup
    klass_name[0] = klass_name[0,1].upcase
    klass = Class.new(data[:is_a])
    klass.send(:define_method, :tag_name) { tag.to_s }

    if data[:attributes]
      klass.accept_attributes data[:attributes]
    end

    Rxhp::Html.const_set(klass_name, klass)

    Rxhp::Scope.define_element tag, klass, Rxhp::Html
  end
end

[
  :fragment,
  :frag,
  :text,
].each do |name|
  Rxhp::Scope.define_element name, Rxhp::HtmlFragment, Rxhp::Html
end
