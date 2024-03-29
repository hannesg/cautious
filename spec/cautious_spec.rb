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
require File.expand_path(File.join(File.dirname(__FILE__),"../lib/cautious"))

describe Cautious do
  
  describe "ClassMethods autoinclude" do
  
    it "should work" do
      
      module BasicModule
        
        extend Cautious
        
        module ClassMethods
          
          def answer
            return 42
          end
          
        end
        
      end
      
      class T1
      
        include BasicModule
      
      end
      
      T1.should respond_to(:answer)
      T1.answer.should == 42
      
    end
    
    it "should work with submodules" do
      
      module BetterModule
      
        include BasicModule
      
      end
      
      class T2
      
        include BetterModule
      
      end
      
      T2.should respond_to(:answer)
      T2.answer.should == 42
      
      BetterModule.should_not respond_to(:answer)
      
    end
    
  end
end
