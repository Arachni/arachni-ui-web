class Schedule < ActiveRecord::Base
    belongs_to :scan

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
end
