################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
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
module RenderHelper
  ################################################################################
  # render based on the condition
  def conditional_render (condition, options={})
    default_when_false = 
      if @action_name == 'create'
        'new'
      elsif @action_name == 'update'
        'edit'
      end

    configuration = {
      :when_true    => 'show',
      :when_false   => default_when_false,
      :id           => nil,
      :redirect_to  => nil,
    }.merge(options)

    render_options = {}
    render_options[:id] = configuration[:id] if configuration[:id]
    render_options[:project] = @project if @project

    if condition
      render_options[:action] = configuration[:when_true]
    else
      render_options[:action] = configuration[:when_false]
    end

    if !condition and configuration[:redirect_to]
      redirect_to(configuration[:redirect_to])
    else
      render(render_options)
    end
  end

end
################################################################################
