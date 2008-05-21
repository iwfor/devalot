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
module TaggingPlugin
  ################################################################################
  # These methods are added to ActiveRecord::Base as class methods
  module ActiveRecordBaseMethods
    ################################################################################
    # Enable tagging for the calling ActiveRecord model class.
    def acts_as_taggable
      has_many(:taggings, :as => :taggable, :dependent => :destroy)
      has_many(:tags, :through => :taggings, :order => :name, :extend => ExtendTagsAssociation)
    end

    ################################################################################
    # These methods are added as extensions to the tags association on your
    # model.  It's important that you use these methods to create and destroy
    # tags, so that the reference counts are correct and tag clouds are
    # accurate.
    module ExtendTagsAssociation
      ################################################################################
      # Add the list of tags to this instance of your model:
      #
      #  article.tags.add("ruby apple pmade")
      def add (tag_list)
        Tag.transaction do
          Tag.parse(tag_list).each do |name|
            tag = Tag.find_or_initialize_by_name(name)
            tag.reference_count ||= 0

            next if proxy_owner.taggings.find_by_tag_id(tag.id)
            tag.reference_count += 1
            tag.save!
            tagging = proxy_owner.taggings.build(:tag => tag)
            proxy_owner.tagging_added(tagging) if proxy_owner.respond_to?(:tagging_added)
            tagging.save!
          end
        end

        proxy_owner.tags(true)
      end

      ################################################################################
      # Remove the tags listed from this instance of your model:
      #
      #  article.tags.remove("python")
      def remove (tag_list)
        Tag.transaction do
          Tag.parse(tag_list).each do |name|
            next unless tag = Tag.find_by_name(name)
            next unless tagging = proxy_owner.taggings.find_by_tag_id(tag.id)
            proxy_owner.tagging_removed(tagging) if proxy_owner.respond_to?(:tagging_removed)
            tagging.destroy
          end
        end

        proxy_owner.tags(true)
      end

      ################################################################################
      # Sane way to display all tags, good for stuff like:
      #
      #  <%= article.tags %>
      def to_s
        self.map {|t| t.name.match(/\s/) ? %Q("#{t.name}") : t.name}.join(" ")
      end

    end
  end
end
################################################################################
