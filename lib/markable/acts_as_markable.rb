module Markable
  module ActsAsMarkable
    extend ActiveSupport::Concern

    included do |a|
    end

    module ClassMethods
      def markable_as(marks, options = {})
        Markable.set_models ActiveRecord::Base.connection.tables.collect{|t| t.classify rescue nil }.compact

        cattr_accessor :markable_marks

        if options[:by]
          markers = options[:by].kind_of?(Array) ? options[:by].map { |i| i.to_sym } : [ options[:by].to_sym ]
        else
          markers = :all
        end

        self.markable_marks ||= {}
        marks = [ marks ] unless marks.kind_of? Array
        marks.each { |mark|
          self.markable_marks[ mark.to_sym ] = {
            :allowed_markers => markers
          }
        }

        class_eval do
          has_many :markable_marks, :class_name => 'Markable::Mark', :as => :markable
          include Markable::ActsAsMarkable::MarkableInstanceMethods

          def self.marked_as mark, options = {}
            if options[:by]
              result = self.joins(:markable_marks).where( :marks => { :mark => mark, :marker_id => options[:by].id, :marker_type => options[:by].class.name } )
              markable = self
              result.class_eval do
                define_method :<< do |object|
                  if object.kind_of?(markable) || (object.kind_of?(Array) && object.all?{ |i| i.kind_of?(markable) })
                    options[:by].set_mark mark, object
                  else
                    raise Markable::WrongMarkableType.new
                  end
                end
                define_method :delete do |markable|
                  options[:by].remove_mark mark, markable
                end
              end
            else
              result = self.joins(:markable_marks).where( :marks => { :mark => mark } )
            end
            result
          end
        end

        self.markable_marks.each { |mark, o|
          class_eval %(
            def self.marked_as_#{mark}(options = {})
              self.marked_as :#{mark}, options
            end

            def marked_as_#{mark}? options = {}
              self.marked_as? :#{mark}, options
            end
          )
        }

        Markable.add_markable self
      end
    end

    module MarkableInstanceMethods
      def mark_as(mark, markers)
        markers = [ markers ] unless markers.kind_of? Array
        markers.each { |marker|
          Markable.can_mark_or_raise? marker, self, mark
          params = {
            :markable_id => self.id,
            :markable_type => self.class.name,
            :marker_id => marker.id,
            :marker_type => marker.class.name,
            :mark => mark
          }
          Markable::Mark.create( params ) unless Markable::Mark.exists?( params )
        }
        true
      end

      def marked_as?(mark, options = {})
        if options[:by]
          Markable.can_mark_or_raise? options[:by], self, mark
        end
        params = {
          :markable_id => self.id,
          :markable_type => self.class.name,
          :mark => mark
        }
        if options[:by]
          params[:marker_id] = options[:by].id
          params[:marker_type] = options[:by].class.name
        end
        Markable::Mark.exists?( params )
      end

      def unmark mark, options = {}
        if options[:by]
          Markable.can_mark_or_raise? options[:by], self, mark
          markers = options[:by].kind_of?(Array) ? options[:by] : [ options[:by] ]
          markers.each { |marker|
            params = {
              :markable_id => self.id,
              :markable_type => self.class.name,
              :marker_id => marker.id,
              :marker_type => marker.class.name,
              :mark => mark
            }
            Markable::Mark.delete_all(params)
          }
        else
          params = {
            :markable_id => self.id,
            :markable_type => self.class.name,
            :mark => mark
          }
          Markable::Mark.delete_all(params)
        end
        true
      end

      def have_marked_as_by(mark, target)
        result = target.joins(:marker_marks).where( :marks => { :mark => mark, :markable_id => self.id, :markable_type => self.class.name } )
        markable = self
        result.class_eval do
          define_method :<< do |markers|
            markers = [ markers ] unless markers.kind_of? Array
            markers.each { |marker|
              marker.set_mark mark, markable
            }
            self
          end
          define_method :delete do |markers|
            Markable.can_mark_or_raise? markers, markable, mark
            markers = [ markers ] unless markers.kind_of? Array
            markers.each { |marker|
              marker.remove_mark mark, markable
            }
            self
          end
        end
        result
      end
    end
  end
end

ActiveRecord::Base.send :include, Markable::ActsAsMarkable
