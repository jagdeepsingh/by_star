module ByStar

  module Between

    # TODO: Apply default offset here?!?!
    # OFFSET should only apply to DATE!!
    # date overlap may need gte
    def between_times(*args)
      options = args.extract_options!.symbolize_keys!

      raise 'ByStar :order option has been retired as of version 3. Please use ActiveRecord #order method instead.' if options[:order]

      # Do not apply default offset here
      offset = (options[:offset] || 0).seconds
      range = if args[0].is_a?(Range)
                (args[0].first + offset)..(args[0].last + offset)
              else
                (args[0] + offset)..(args[1] + offset)
              end

      start_field = by_star_start_field(options)
      end_field = by_star_end_field(options)
      scope = by_star_scope(options)

      scope = if start_field == end_field
                by_star_point_query(scope, start_field, range)
              elsif options[:strict]
                by_star_strict_span_query(scope, start_field, end_field, range)
              else
                by_star_overlap_span_query(scope, start_field, end_field, range, options)
              end

      scope
    end

    def by_day(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.time(time)
        between_times_with_default_offset(time.beginning_of_day, time.end_of_day, options)
      end
    end

    def by_week(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.week(time, options)
        start_day = Array(options[:start_day])
        between_times_with_default_offset(time.beginning_of_week(*start_day), time.end_of_week(*start_day), options)
      end
    end

    def by_cweek(*args)
      with_by_star_options(*args) do |time, options|
        by_week(ByStar::Normalization.cweek(time, options), options)
      end
    end

    def by_weekend(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.week(time, options)
        between_times_with_default_offset(time.beginning_of_weekend, time.end_of_weekend, options)
      end
    end

    def by_fortnight(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.fortnight(time, options)
        between_times_with_default_offset(time.beginning_of_fortnight, time.end_of_fortnight, options)
      end
    end

    def by_month(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.month(time, options)
        between_times_with_default_offset(time.beginning_of_month, time.end_of_month, options)
      end
    end

    def by_calendar_month(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.month(time, options)
        start_day = Array(options[:start_day])
        between_times_with_default_offset(time.beginning_of_calendar_month(*start_day), time.end_of_calendar_month(*start_day), options)
      end
    end

    def by_quarter(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.quarter(time, options)
        between_times_with_default_offset(time.beginning_of_quarter, time.end_of_quarter, options)
      end
    end

    def by_year(*args)
      with_by_star_options(*args) do |time, options|
        time = ByStar::Normalization.year(time, options)
        between_times_with_default_offset(time.beginning_of_year, time.end_of_year, options)
      end
    end

    def today(options={})
      by_day(Time.zone.now, options)
    end

    def yesterday(options={})
      by_day(Time.zone.now.yesterday, options)
    end

    def tomorrow(options={})
      by_day(Time.zone.now.tomorrow, options)
    end

    def past_day(options={})
      between_times_with_default_offset(Time.zone.now - 1.day, Time.zone.now, options)
    end

    def past_week(options={})
      between_times_with_default_offset(Time.zone.now - 1.week, Time.zone.now, options)
    end

    def past_fortnight(options={})
      between_times_with_default_offset(Time.zone.now - 1.fortnight, Time.zone.now, options)
    end

    def past_month(options={})
      between_times_with_default_offset(Time.zone.now - 1.month, Time.zone.now, options)
    end

    def past_year(options={})
      between_times_with_default_offset(Time.zone.now - 1.year, Time.zone.now, options)
    end

    def next_day(options={})
      between_times_with_default_offset(Time.zone.now, Time.zone.now + 1.day, options)
    end

    def next_week(options={})
      between_times_with_default_offset(Time.zone.now, Time.zone.now  + 1.week, options)
    end

    def next_fortnight(options={})
      between_times_with_default_offset(Time.zone.now, Time.zone.now + 1.fortnight, options)
    end

    def next_month(options={})
      between_times_with_default_offset(Time.zone.now, Time.zone.now + 1.month, options)
    end

    def next_year(options={})
      between_times_with_default_offset(Time.zone.now, Time.zone.now + 1.year, options)
    end

    private

    def between_times_with_default_offset(start_time, end_time, options)
      options[:offset] ||= by_star_default_offset(options)
      between_times(start_time, end_time, options)
    end
  end
end