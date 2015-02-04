angular.module('angular-date-picker-polyfill')
  .factory 'aaDateUtil', ->
    dateObjectsAreEqualToDay: (d1, d2) ->
      return false unless angular.isDate(d1) && angular.isDate(d2)
      (d1.getFullYear() == d2.getFullYear()) &&
        (d1.getMonth() == d2.getMonth()) &&
        (d1.getDate() == d2.getDate())

    dateObjectsAreEqualToMonth: (d1, d2) ->
      return false unless angular.isDate(d1) && angular.isDate(d2)
      (d1.getFullYear() == d2.getFullYear()) &&
        (d1.getMonth() == d2.getMonth())

    convertToDate: (val) ->
      if angular.isDate(val)
        val
      else
        d = Date.parse(val)
        if angular.isDate(d) then d else null
