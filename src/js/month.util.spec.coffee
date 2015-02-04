describe 'aaMonthUtil', ->
  util = null
  beforeEach(angular.mock.module('angular-date-picker-polyfill'))

  beforeEach(inject((_aaMonthUtil_) ->
    util = _aaMonthUtil_
    return
  ))

  describe 'numberOfDaysInMonth', ->
    it 'is correct for a bunch of examples', ->
      # Remember, the months are zero indexed
      expect(util.numberOfDaysInMonth(2015, 0)).toEqual(31)
      expect(util.numberOfDaysInMonth(2015, 1)).toEqual(28)

  describe 'generateMonthArray', ->
    monthArr = null
    today = null
    describe 'for February 2015', ->
      beforeEach -> 
        monthArr = util.generateMonthArray(2015, 1)
      it 'returns an array of 4 nested arrays, each with 7 days', ->
        expect(monthArr.length).toEqual(4)
        for week in monthArr
          expect(week.length).toEqual(7)

      it 'has the 1st at [0][0] and the 28th at [3][6]', ->
        expect(monthArr[0][0].date.getDate()).toEqual(1)
        expect(monthArr[3][6].date.getDate()).toEqual(28)

    describe 'for May 2015', ->
      beforeEach ->
        monthArr = util.generateMonthArray(2015, 4)

      it 'returns an array of 6 nested arrays, each with 7 days', ->
        expect(monthArr.length).toEqual(6)
        for week in monthArr
          expect(week.length).toEqual(7)

      it 'has the first 5 days of April 2015 in week 1', ->
        expect(monthArr[0][0].date.toDateString()).toEqual('Sun Apr 26 2015')
        expect(monthArr[0][4].date.toDateString()).toEqual('Thu Apr 30 2015')
        expect(monthArr[0][5].date.toDateString()).toEqual('Fri May 01 2015')

      it 'has the first 6 days of June 2015 in week 6', ->
        expect(monthArr[5][0].date.toDateString()).toEqual('Sun May 31 2015')
        expect(monthArr[5][1].date.toDateString()).toEqual('Mon Jun 01 2015')
        expect(monthArr[5][6].date.toDateString()).toEqual('Sat Jun 06 2015')

      it 'flags dates that are not in May 2015', ->
        expect(monthArr[0][0].isOtherMonth).toEqual(true)
        expect(monthArr[0][4].isOtherMonth).toEqual(true)
        expect(monthArr[0][5].isOtherMonth).toEqual(false)
        expect(monthArr[5][0].isOtherMonth).toEqual(false)
        expect(monthArr[5][1].isOtherMonth).toEqual(true)
        expect(monthArr[5][6].isOtherMonth).toEqual(true)


    describe 'with a selected date', ->
      it 'flags the selected date', ->
        expect(hasSelected(util.generateMonthArray(2015, 4, (new Date(2015, 4, 10))))).toEqual(true)
        expect(hasSelected(util.generateMonthArray(2015, 3, (new Date(2015, 4, 10))))).toEqual(false)
        expect(hasSelected(util.generateMonthArray(2015, 4, (new Date(2014, 4, 10))))).toEqual(false)

    describe 'for the current month', ->
      beforeEach ->
        today = new Date()

      it 'flags todays date', ->
        thisMonth = util.generateMonthArray(today.getFullYear(), today.getMonth())
        nextMonth = util.generateMonthArray(today.getFullYear(), today.getMonth() + 1)
        nextYear = util.generateMonthArray(today.getFullYear() + 1, today.getMonth() )
        expect(hasToday(thisMonth)).toEqual(true)
        expect(hasToday(nextMonth)).toEqual(false)
        expect(hasToday(nextYear)).toEqual(false)


hasToday = (arr) ->
  todayCount = 0
  for week in arr
    for day in week
      if day.isToday
        todayCount += 1
  todayCount == 1

hasSelected = (arr) ->
  sCount = 0
  for week in arr
    for day in week
      if day.isSelected
        sCount += 1
  sCount == 1
