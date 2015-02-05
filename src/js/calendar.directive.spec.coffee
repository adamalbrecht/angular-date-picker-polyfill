monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]

curMonthName = ->
  monthNames[(new Date()).getMonth()]

describe 'aaCalendar', ->
  element =  null
  scope = null
  $compile = null
  cal = null

  beforeEach(angular.mock.module('angular-date-picker-polyfill'))
  beforeEach(inject((_$compile_, $rootScope) ->
    scope = $rootScope.$new()
    $compile = _$compile_
    return
  ))

  buildCalendar = (model) ->
    scope.myDate = model
    element = $compile("<div aa-calendar ng-model='myDate'></div>")(scope)
    scope.$digest()
    new CalInterface(element)

  describe 'a basic calendar set to null', ->
    beforeEach -> cal = buildCalendar(null)

    it 'defaults to the current month', ->
      expect(cal.getMonthName()).toEqual("#{curMonthName()} #{(new Date()).getFullYear()}")

    it "adds a special class to today's date", ->
      expect($(element).find("table td.aa-cal-today").length).toEqual(1)

    it 'does not add the selected class to any date', ->
      expect($(element).find('.aa-cal-selected').length).toEqual(0)

    it 'has a header row of day abbreviations', ->
      expect($(element).find("table thead tr th:nth-child(1)").text()).toEqual("Su")
      expect($(element).find("table thead tr th:nth-child(2)").text()).toEqual("M")

  describe 'a calendar set to February 1st, 2015', ->
    beforeEach -> cal = buildCalendar(new Date(2015, 1, 1))
    it 'has the first Sunday as Feb 1st', ->
      cell = cal.getDateCell(0, 0)
      expect($(cell).text().trim()).toEqual('1')

  describe 'a calendar set to April 9, 2015', ->
    beforeEach -> cal = buildCalendar(new Date(2015, 3, 9))
    it 'shows the month name and year', ->
      expect(cal.getMonthName()).toEqual 'April 2015'

    it 'has the first Sunday as March 29th', ->
      cell = cal.getDateCell(0, 0)
      expect($(cell).text().trim()).toEqual('29')

    it "Adds 'other' classes to the first 3 days since they are part of March", ->
      $sun = cal.getDateCell(0, 0)
      $mon = cal.getDateCell(0, 1)
      $tue = cal.getDateCell(0, 2)
      $wed = cal.getDateCell(0, 3)
      expect($sun.text().trim()).toEqual('29')
      cls = "aa-cal-other-month"
      for day in [$sun, $mon, $tue]
        expect(day.hasClass(cls)).toBeTruthy()
      expect($wed.hasClass(cls)).toBeFalsy()

    it "Adds 'other' classes to the last 2 days since they are part of May", ->
      $thu = cal.getDateCell("last", 4)
      $fri = cal.getDateCell("last", 5)
      $sat = cal.getDateCell("last", 6)
      expect($thu.text().trim()).toEqual('30')
      cls = "aa-cal-other-month"
      expect($thu.hasClass(cls)).toBeFalsy()
      for day in [$fri, $sat]
        expect(day.hasClass(cls)).toBeTruthy()

    it 'applies the selected class to the selected date model cell', ->
      expect(cal.getDateCell(1, 4).hasClass('aa-cal-selected')).toBeTruthy()

    describe 'And I click the Next month button', ->
      beforeEach ->
        cal.clickNextMonth()

      it 'updates the month name to May', ->
        expect(cal.getMonthName()).toEqual("May 2015")

    describe 'And I click the Prev month button', ->
      beforeEach ->
        cal.clickPrevMonth()

      it 'updates the month name to March', ->
        expect(cal.getMonthName()).toEqual("March 2015")

    describe 'And I click the next year button', ->
      beforeEach ->
        cal.clickNextYear()

      it 'updates the year in the title to 2015', ->
        expect(cal.getMonthName()).toEqual("April 2016")

    describe 'And I click the prev year button', ->
      beforeEach ->
        cal.clickPrevYear()

      it 'updates the year in the title to 2014', ->
        expect(cal.getMonthName()).toEqual("April 2014")

    describe 'And I click on April 15', ->
      beforeEach ->
        cal.clickCalendarCell(2, 3)

      it 'updates the selected date model to April 15', ->
        expect(scope.myDate.getMonth()).toEqual(3)
        expect(scope.myDate.getDate()).toEqual(15)

      it 'applies the selected class to the cell and no other cells', ->
        expect(cal.getDateCell(2, 3).hasClass('aa-cal-selected')).toBeTruthy()
        expect($(element).find('.aa-cal-selected').length).toEqual(1)

    describe 'And I click on March 29', ->
      beforeEach ->
        cal.clickCalendarCell(0, 0)

      it 'updates the selected date model to March 29', ->
        expect(scope.myDate.getMonth()).toEqual(2)
        expect(scope.myDate.getDate()).toEqual(29)

      it 'switches the month to March', ->
        expect(cal.getMonthName()).toEqual("March 2015")

      it 'updates the date model on the scope', ->
        expect(scope.myDate.getMonth()).toEqual(2) # 0-indexed months

    describe 'And the selected date is changed to July 1 outside the directive', ->
      beforeEach ->
        scope.myDate = new Date(2015, 6, 1)
        scope.$apply()

      it 'switches the calendar to July', ->
        expect(cal.getMonthName()).toEqual("July 2015")

    describe 'And the selected date is changed to null outside the directive', ->
      beforeEach ->
        scope.myDate = null
        scope.$apply()

      it 'removes the selected class from the cell', ->
        expect($(element).find('.aa-cal-selected').length).toEqual(0)

      it 'resets the calendar to the current month', ->
        expect(cal.getMonthName()).toEqual("#{curMonthName()} #{(new Date()).getFullYear()}")

  describe 'a calendar whose model is set to May 15, 2015', ->
    beforeEach -> cal = buildCalendar(new Date(2015, 4, 15))

    it 'shows the 1st on the first friday', ->
      expect(cal.getDateCell(0, 5).text().trim()).toEqual("1")






class CalInterface
  constructor: (element) ->
    @element = $(element)
    @scope = element.scope()


  getMonthName: =>
    $(@element).find('.aa-cal-month-name').text()

  getTodayCell: =>
    $(@element).find('table tbody .aa-cal-today')

  getDateCell: (w, d) =>
    weekSelector = if typeof w == "string" then w else "nth-child(#{w + 1})"
    daySelector = if typeof d == "string" then d else "nth-child(#{d + 1})"
    $(@element).find("table tbody tr:#{weekSelector} td:#{daySelector}")

  clickNextMonth: =>
    $(@element).find(".aa-cal-next-month").click()

  clickPrevMonth: =>
    $(@element).find(".aa-cal-prev-month").click()

  clickNextYear: =>
    $(@element).find(".aa-cal-next-year").click()

  clickPrevYear: =>
    $(@element).find(".aa-cal-prev-year").click()

  clickCalendarCell: (w, d) =>
    $td = @getDateCell(w, d)
    $td.click()
