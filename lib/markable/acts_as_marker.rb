module Markable
  module ActsAsMarker
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_marker(options = {})
        Markable.set_models ActiveRecord::Base.connection.tables.collect{|t| t.classify rescue nil }.compact

        cattr_accessor :marker_name
        self.marker_name = self.name.downcase.to_sym

        class_eval do
          has_many :marker_marks, :class_name => 'Markable::Mark', :as => :marker
        end
        class_eval do
          include Markable::ActsAsMarker::MarkerInstanceMethods
        end
        Markable.add_marker self
      end
    end

    module MarkerInstanceMethods
      def method_missing( method_sym, *args )
        Markable.models.each { |model_name|
          if method_sym.to_s =~ Regexp.new("^[\\w_]+_#{model_name.downcase.pluralize}$") ||
              method_sym.to_s =~ Regexp.new("^#{model_name.downcase.pluralize}_marked_as(_[\\w_]+)?$")
            model_name.constantize # ping model
            if self.methods.include? method_sym # method has appear
              return self.method(method_sym).call(args) if args.count > 0 # call this method
              return self.method(method_sym).call
            end
          end
        }
        super
      rescue
        super
      end

      def set_mark_to mark, markables
        markables = [ markables ] unless markables.kind_of? Array
        markables.each do |markable|
          Markable.can_mark_or_raise? self, markable, mark
          markable.mark_as mark, self
        end
      end

      def remove_mark_from mark, markables
        markables = [ markables ] unless markables.kind_of? Array
        Markable.can_mark_or_raise? self, markables, mark
        markables.each do |markable|
          markable.remove_mark mark, :by => self
        end
      end
    end

  end
end

ActiveRecord::Base.send :include, Markable::ActsAsMarker
