module ByStar

  module Base

    include ByStar::Between
    include ByStar::Directional

    def by_star_field(*args)
      options = args.extract_options!
      @by_star_start_field ||= args[0]
      @by_star_end_field   ||= args[1]
      @by_star_offset      ||= options[:offset]
      @by_star_scope       ||= options[:scope]
    end

    # # Default offset is only applied
    # def by_star_offset(options = {})
    #   offset = options[:offset]
    #   offset ||= @by_star_offset unless options[:field] && options[:field] != @by_star_start_field
    #   offset ||= 0
    #   offset.seconds
    # end

    # Default offset is only applied ...
    def by_star_default_offset(options = {})
      @by_star_offset unless options[:field] && options[:field] != @by_star_start_field
    end

    def by_star_start_field(options={})
      field = options[:field] ||
          options[:start_field] ||
          @by_star_start_field ||
          by_star_default_field
      field.to_s
    end

    def by_star_end_field(options={})
      field = options[:field] ||
          options[:end_field] ||
          @by_star_end_field ||
          by_star_start_field
      field.to_s
    end

    def by_star_scope(options={})
      scope = options[:scope] || @by_star_scope || self
      if scope.is_a?(Proc)
        if scope.arity == 0
          return instance_exec(&scope)
        elsif options[:scope_args]
          return instance_exec(*Array(options[:scope_args]), &scope)
        else
          raise 'ByStar :scope Proc requires :scope_args to be specified.'
        end
      else
        return scope
      end
    end

    protected

    # Wrapper function which extracts time and options for each by_star query.
    # :offset is also set to the class default if not present.
    # Note the following syntax examples are valid:
    #
    #   Post.by_month                      # defaults to current time
    #   Post.by_month(2, :year => 2004)    # February, 2004
    #   Post.by_month(Time.now)
    #   Post.by_month(Time.now, :field => "published_at")
    #   Post.by_month(:field => "published_at")
    #
    def with_by_star_options(*args, &block)
      options = args.extract_options!.symbolize_keys!
      time = args.first || Time.zone.now
      block.call(time, options)
    end

    def by_star_eval_index_start(range, options)
      value = options[:index_start]
      value = value.call(range, options) if value.is_a?(Proc)
      case value
        when nil, false then nil
        when Time then value
        when DateTime then value.to_time
        when Date then value.in_time_zone
        when ActiveSupport::Duration then range.first - value
        when Numeric then range.first - value.seconds
        when :beginning_of_day
          offset = options[:offset] || by_star_default_offset(options) || 0
          (range.first - offset).beginning_of_day + offset
        else raise 'ByStar :index_start option value is not a supported type.'
      end
    end
  end
end