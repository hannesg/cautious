# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2010 by Hannes Georg
#

#
# Have you ever overloaded :included or :extended ?
# Well you code might look like this:
#
# module A
#   class << self
#     def included(base)
#       if base.kind_of?(Class)
#         base.extend(FancyClassMethods)
#       end
#     end
#   end
#   
#   module FancyClassMethods
#     ... bla ...
#   end
#
# end
#
# Have we forgotten something? Yep - we don't call super in included.
# But apart from that it seems reasonable, however think about the following:
#
# module B
#   include A
# end
# 
# When you now include B A.included is not called again thought this might be wanted.
# However: if you extend A with Cautious this will be done automatically!
#
# module A2
#   extend Cautious
#
#   when_included do |base|
#       if base.kind_of?(Class)
#         base.extend(FancyClassMethods)
#       end
#   end
#   
#   module FancyClassMethods
#     ... bla ...
#   end
#
# end
#
# module B2
#   include A2
# end
# 
# You can now include B2 in any class and this class will be extended with FancyClassMethods!
#
# Furthermore this module automatically search for a constant named ClassMethods in and includes this.
# So the example above could also be written as:
# module A3
#   extend Cautious
#
#   module ClassMethods
#     ... bla ...
#   end
#
# end
#
# module B3
#   include A3
# end
#
# Perfect! Less repetetive code.
# 
module Cautious
  
  module SlightlyCautious
    
    def included(base)
      self.included_modules.reverse_each do |mod|
        #next unless mod.kind_of? SlightlyCautious
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      super
      if base.method(:included).owner == Module
        base.extend(SlightlyCautious)
      end
    end
    
    def inherited(base)
      if base.method(:inherited).owner == Class
        base.extend(SlightlyCautious)
      end
      super
    end
    
    def extended(base)
      if !base.respond_to? :extended
        if self.const_defined?('ClassMethods')
          base.extend(self::ClassMethods)
        end
        return 
      end
      if base.method(:extended).owner == Module
        base.extend(SlightlyCautious)
      end
      super
    end
    
  end
  
  include SlightlyCautious
  
  def included(base)
    if base.kind_of? Class
      if self.const_defined?('ClassMethods')
        base.extend(self::ClassMethods)
      end
    else
      if self.const_defined?('ModuleMethods')
        base.extend(self::ModuleMethods)
      end
    end
    if instance_variable_defined? :@cautious_included_block and @cautious_included_block
      @cautious_included_block.call(base)
    end
    super
  end
  
  def inherited(base)
    super
    if @cautious_inherited_block
      @cautious_inherited_block.call(base)
    end
  end
  
  def extended(base)
    super
    if @cautious_extended_block
      @cautious_extended_block.call(base)
    end
  end
  
  def self.extended(base)
    base.extend(SlightlyCautious)
  end
  
  # Create a callback, which is fired whenever this module is included.
  def when_included(&block)
    @cautious_included_block = block
  end
  
  # Create a callback, which is fired whenever this class is inherited.
  def when_inherited(&block)
    @cautious_inherited_block = block
  end
  
  # Create a callback, which is fired whenever this module is extend.
  def when_extended(&block)
    @cautious_extended_block = block
  end
  
end
