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
class TicketsController < ApplicationController
  ################################################################################
  def list
    @tickets = @project.tickets
  end

  ################################################################################
  def show
    # FIXME should I limit this to the current project
    @ticket = Ticket.find(params[:id])
  end

  ################################################################################
  def new
    @ticket = Ticket.new
  end

  ################################################################################
  def create
    strip_invalid_keys(params[:ticket], :summary, :severity_id)
    @ticket = Ticket.create(params[:ticket], @project, current_user)

    if @ticket.valid?
      render(:text => 'Valid!')
      return
    end

    raise @ticket.errors.inspect
    render(:action => 'new')
  end

end
################################################################################
