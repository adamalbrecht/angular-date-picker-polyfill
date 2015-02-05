describe 'aaTimeUtil', ->
  util = null
  beforeEach(angular.mock.module('angular-date-picker-polyfill'))

  beforeEach(inject((_aaTimeUtil_) ->
    util = _aaTimeUtil_
    return
  ))

  describe 'getMinuteAndHourFromDate', ->
    d = null
    amPm = null
    getResult = -> util.getMinuteAndHourFromDate(d, amPm)
    describe 'on a date set to 12:30am', ->
      beforeEach -> d = new Date(2015, 1, 5, 0, 30)
      describe 'when using AM/PM', ->
        beforeEach -> amPm = true
        it 'returns [12, 30, am]', ->
          expect(getResult()).toEqual([12, 30, 'AM'])
      describe 'when not using AM/PM', ->
        beforeEach -> amPm = false
        it 'returns [0, 30]', ->
          expect(getResult()).toEqual([0, 30, null])
    describe 'on a date set to 12:30pm', ->
      beforeEach -> d = new Date(2015, 1, 5, 12, 30)
      describe 'when using AM/PM', ->
        beforeEach -> amPm = true
        it 'returns [12, 30, pm]', ->
          expect(getResult()).toEqual([12, 30, 'PM'])
      describe 'when not using AM/PM', ->
        beforeEach -> amPm = false
        it 'returns [0, 30]', ->
          expect(getResult()).toEqual([12, 30, null])


  describe 'applyTimeValuesToDateObject', ->
    d = null
    describe 'given a date object set to 0:00:00', ->
      beforeEach -> d = new Date(2015, 1, 5, 0, 0, 0)
      it 'can be set to 5:05 pm', ->
        util.applyTimeValuesToDateObject([5, 5, 'PM'], d)
        expect(d.getHours()).toEqual(17)
        expect(d.getMinutes()).toEqual(5)

      it 'can be set to 12pm', ->
        util.applyTimeValuesToDateObject([12, 0, 'PM'], d)
        expect(d.getHours()).toEqual(12)
        expect(d.getMinutes()).toEqual(0)

      it 'can be set to 8am', ->
        util.applyTimeValuesToDateObject([8, 0, 'AM'], d)
        expect(d.getHours()).toEqual(8)
        expect(d.getMinutes()).toEqual(0)

      it 'can be set to 8pm', ->
        util.applyTimeValuesToDateObject([8, 0, 'PM'], d)
        expect(d.getHours()).toEqual(20)
        expect(d.getMinutes()).toEqual(0)

      it 'can be set to 8am via 24-hour time', ->
        util.applyTimeValuesToDateObject([8, 0], d)
        expect(d.getHours()).toEqual(8)
        expect(d.getMinutes()).toEqual(0)

      it 'can be set to 8pm via 24-hour time', ->
        util.applyTimeValuesToDateObject([20, 0], d)
        expect(d.getHours()).toEqual(20)
        expect(d.getMinutes()).toEqual(0)
