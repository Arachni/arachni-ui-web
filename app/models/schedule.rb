=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

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
    BASETIME_OPTIONS = {
        finished_at: 'Finish time',
        started_at:  'Start time'
    }

    has_many :scans

    scope :due, -> { joins(:scans).where( scans: { status: 'scheduled' } ).where [ 'start_at <= ?', Time.now ] }

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
    validates :basetime, inclusion: { in: BASETIME_OPTIONS.keys }

    def recurring?
        interval > 0
    end

    def interval
        every_minute.to_i.minutes + every_hour.to_i.hours +
            every_day.to_i.days + every_month.to_i.months
    end

    def basetime
        super.to_s.to_sym
    end

end
