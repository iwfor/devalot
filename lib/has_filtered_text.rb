################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
module HasFilteredText
  ################################################################################
  module ClassMethods
    ################################################################################
    def has_filtered_text (attribute=:filtered_text)
      ################################################################################
      # Establish the relationship
      belongs_to(attribute, :class_name => 'FilteredText', :foreign_key => "#{attribute}_id")

      ################################################################################
      # Auto save when the parent is saved
      before_save {|owner| if ft = owner.send(attribute) then ft.save end}

      ################################################################################
      # Auto destroy when the parent is destroyed
      after_destroy {|owner| if ft = owner.send(attribute) then ft.destroy end}

      ################################################################################
      # Simple method to create or update a filtered_text object
      define_method("update_#{attribute}") do |params_hash, user|
        if ft = self.send(attribute)
          ft.attributes = params_hash
          ft.updated_by = user
        else
          ft = self.send("build_#{attribute}", params_hash)
          ft.created_by = user
          ft.updated_by = user
        end
      end
    end

  end
end
################################################################################
