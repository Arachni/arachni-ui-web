class DatetimeValidator < ActiveModel::EachValidator
    def validate_each( record, attribute, value )
        before_type_cast = "#{attribute}_before_type_cast"

        raw_value = record.send( before_type_cast ) if record.respond_to?( before_type_cast.to_sym )
        raw_value ||= value

        return if raw_value.blank?
        raw_value.to_datetime rescue record.errors[attribute] << (options[:message] || 'must be a datetime.')
    end
end

class Schedule < ActiveRecord::Base
    belongs_to :scan

    scope :due, -> { joins(:scan).where( scans: { status: 'scheduled' } ).where [ 'start_at <= ?', Time.now ] }

    validates :every_minute,
              numericality: true,
              inclusion: {
                  in:       1...60,
                  message: 'Accepted values: 1-59.'
              },
              allow_nil: true

    validates :every_hour,
              numericality: true,
              inclusion: {
                  in:       1...24,
                  message: 'Accepted values: 1-23.'
              },
              allow_nil: true

    validates :every_day,
              numericality: true,
              inclusion: {
                  in:       1..29,
                  message: 'Accepted values: 1-29.'
              },
              allow_nil: true

    validates :every_month,
              numericality: true,
              inclusion: {
                  in:       1..12,
                  message: 'Accepted values: 1-12.'
              },
              allow_nil: true

    validates :start_at, datetime: true

    def recurring?
        interval > 0
    end

    def interval
        every_minute.to_i.minutes + every_hour.to_i.hours +
            every_day.to_i.days + every_month.to_i.months
    end

end
