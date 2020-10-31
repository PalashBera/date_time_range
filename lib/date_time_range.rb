require "active_support/core_ext/integer"
require "active_support/core_ext/date"
require "active_support/core_ext/date_time"

class DateTimeRange
  def self.datetime_parse(string)
    @now = DateTime.now.utc
    @units = %w(minute hour day week month year)
    start_datetime, end_datetime = parse(string)

    if start_datetime && end_datetime
      (start_datetime..end_datetime)
    else
      nil
    end
  end

  def self.date_parse(string)
    @now = Date.today
    @units = %w(week month year)
    start_date, end_date = parse(string)

    if start_date && end_date
      (start_date..end_date)
    else
      nil
    end
  end

  private

  def self.rejex_patterns
    {
      this_unit:   /\Athis_(#{@units.join("|")})\Z/,
      prev_unit:   /\Aprevious_(#{@units.join("|")})s?\Z/,
      prev_n_unit: /\Aprevious_(\d+)_(#{@units.join("|")})s?\Z/,
      next_unit:   /\Anext_(#{@units.join("|")})s?\Z/,
      next_n_unit: /\Anext_(\d+)_(#{@units.join("|")})s?\Z/
    }
  end

  def self.parse(string)
    case string
    when rejex_patterns[:this_unit]
      unit = rejex_patterns[:this_unit].match(string)[1]
      [
        @now.public_send("beginning_of_#{unit}"),
        @now.public_send("end_of_#{unit}")
      ]
    when rejex_patterns[:prev_n_unit]
      matches = rejex_patterns[:prev_n_unit].match(string)
      n, unit = matches[1], matches[2]
      [
        @now.public_send("beginning_of_#{unit}")  - Integer(n).public_send(unit),
        @now.public_send("end_of_#{unit}") - 1.public_send(unit)
      ]
    when rejex_patterns[:next_n_unit]
      matches = rejex_patterns[:next_n_unit].match(string)
      n, unit = matches[1], matches[2]
      [
        @now.public_send("beginning_of_#{unit}")  + 1.public_send(unit),
        @now.public_send("end_of_#{unit}") + Integer(n).public_send(unit)
      ]
    when rejex_patterns[:prev_unit]
      unit = rejex_patterns[:prev_unit].match(string)[1]
      parse("prev_1_#{unit}")
    when rejex_patterns[:next_unit]
      unit = rejex_patterns[:next_unit].match(string)[1]
      parse("next_1_#{unit}")
    when "today"
      parse("this_day")
    when "yesterday"
      parse("prev_day")
    when "tomorrow"
      parse("next_day")
    end
  end
end
