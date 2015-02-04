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

  buildCalendar = (model, year=null, month=null) ->
    scope.model = model
    scope.year = year
    scope.month = month
    element = $compile("<div aa-calendar ng-model='model' month='month' year='year'></div>")(scope)
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

  describe 'a calendar set to February 2015', ->
    beforeEach -> cal = buildCalendar(2015, 1)
    it 'has the first Sunday as Feb 1st', ->
      cell = cal.getDateCell(0, 0)
      expect($(cell).text().trim()).toEqual('1')


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
