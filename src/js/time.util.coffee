angular.module('angular-date-picker-polyfill')
  .factory 'aaTimeUtil', ->
    getMinuteAndHourFromDate: (d, useAmPmHours=true) ->
      return null unless angular.isDate(d)
      h = d.getHours()
      amPm = null
      if useAmPmHours
        switch
          when h == 0
            h = 12
            amPm = 'AM'
          when h == 12
            amPm = 'PM'
          when h > 12
            h = h - 12
            amPm = 'PM'
      m = d.getMinutes()
      [h, m, amPm]

    applyTimeValuesToDateObject: (timeValues, d) ->
      [hour, minute, amPm] = timeValues
      d.setMinutes(minute)
      if amPm == 'AM'
        d.setHours(if hour == 12 then 0 else hour)
      else if amPm == 'PM' && hour == 12
        d.setHours(12)
      else if amPm == 'PM' && hour != 12
        d.setHours(hour + 12)
      else
        d.setHours(hour)
      d
