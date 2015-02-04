angular.module('angular-date-picker-polyfill')
  .factory 'aaMonthUtil', (aaDateUtil) ->
    # zero indexed months
    numberOfDaysInMonth: (year, month) ->
      [31, (if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) then 29 else 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]

    generateMonthArray: (year, month, selected=null) ->
      d = new Date(year, month, 1)
      today = new Date()
      endDate = new Date(year, month, @numberOfDaysInMonth(year, month))
      offset = d.getDay()
      d.setDate(d.getDate() + (offset * -1))
      arr = []
      weekNum = 0
      while d <= endDate
        arr.push([])
        for dayIndex in [0..6]
          obj = {
            date: angular.copy(d),
            isToday: aaDateUtil.dateObjectsAreEqualToDay(d, today),
            isSelected: if (selected && aaDateUtil.dateObjectsAreEqualToDay(d, selected)) then true else false,
            isOtherMonth: d.getMonth() != month
          }
          arr[weekNum].push(obj)
          d.setDate(d.getDate() + 1)
        weekNum += 1
      arr
