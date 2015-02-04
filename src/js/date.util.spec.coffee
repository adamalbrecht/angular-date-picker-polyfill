describe 'aaDateUtil', ->
  util = null
  beforeEach(angular.mock.module('angular-date-picker-polyfill'))

  beforeEach(inject((_aaDateUtil_) ->
    util = _aaDateUtil_
    return
  ))

  describe 'dateObjectsAreEqualToDay', ->
    it 'is true for 2 exact copies of the same date', ->
      d1 = new Date()
      d2 = angular.copy(d1)
      expect(util.dateObjectsAreEqualToDay(d1, d2)).toEqual(true)
    it 'is not true for 2 completely different dates', ->
      d1 = new Date()
      d2 = new Date(2010, 1, 1)
      expect(util.dateObjectsAreEqualToDay(d1, d2)).toEqual(false)


  describe 'dateObjectsAreEqualToMonth', ->
    it 'is true for 2 exact copies of the same date', ->
      d1 = new Date()
      d2 = angular.copy(d1)
      expect(util.dateObjectsAreEqualToMonth(d1, d2)).toEqual(true)
    it 'is true for Jan 1 and Jan 31', ->
      d1 = new Date(2015, 0, 1)
      d2 = new Date(2015, 0, 31)
      expect(util.dateObjectsAreEqualToMonth(d1, d2)).toEqual(true)
    it 'is false for Jan 1 of different years', ->
      d1 = new Date(2015, 0, 1)
      d2 = new Date(2014, 0, 1)
      expect(util.dateObjectsAreEqualToMonth(d1, d2)).toEqual(false)
    it 'is false for Jan 1 and Feb 1', ->
      d1 = new Date(2015, 0, 1)
      d2 = new Date(2015, 1, 1)
      expect(util.dateObjectsAreEqualToMonth(d1, d2)).toEqual(false)
