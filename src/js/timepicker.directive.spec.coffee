areTimesEqual = (d1, d2) ->
  angular.isDate(d1) &&
    angular.isDate(d2) &&
    d1.getHours() == d2.getHours() &&
    d1.getMinutes() == d2.getMinutes()

describe 'aaTimepicker', ->
  element = null
  scope = null
  $compile = null
  picker = null

  beforeEach(angular.mock.module('angular-date-picker-polyfill'))
  beforeEach(inject((_$compile_, $rootScope) ->
    scope = $rootScope.$new()
    $compile = _$compile_
    return
  ))

  buildTimepicker = (model, amPm=null) ->
    scope.myDate = model
    if amPm == null
      element = $compile("<div aa-timepicker ng-model='myDate'></div>")(scope)
    else
      element = $compile("<div aa-timepicker ng-model='myDate' use-am-pm='#{amPm}'></div>")(scope)
    scope.$digest()
    new TimepickerInterface(element)

  describe 'a timepicker with no am-pm value set', ->
    beforeEach -> picker = buildTimepicker(null, null)

    it 'defaults to showing the AM/PM select', ->
      expect($(element).find(".aa-timepicker-ampm").length).toEqual(1)


  describe 'a basic timepicker with am-pm set to true', ->
    beforeEach -> picker = buildTimepicker(null, true)

    it 'defaults to showing the AM/PM select', ->
      expect($(element).find(".aa-timepicker-ampm").length).toEqual(1)

    describe 'with the model set to null', ->
      it 'defaults to blank values', ->
        expect(picker.getTimeShown()).toEqual("")

      describe 'and the hour is set to 5', ->
        beforeEach -> picker.setHourSelect(5)
        it 'sets the time to 5:00 AM', ->
          expect(picker.getTimeShown()).toEqual("5:00 AM")

        describe 'and the minute is set to 28', ->
          beforeEach -> picker.setMinuteSelect(28)
          it 'sets the model to 5:28 AM', ->
            expect(areTimesEqual(scope.myDate, new Date(2015, 1, 1, 5, 28))).toEqual(true)

          describe 'and it is set to PM', ->
            beforeEach -> picker.setAmPmSelect('PM')
            it 'sets the model to 5:28 PM', ->
              dt = new Date(2015, 1, 1, 17, 28)
              expect(areTimesEqual(scope.myDate, dt)).toEqual(true)

    describe 'with the model set to a date at 12:05 AM', ->
      beforeEach ->
        scope.myDate = new Date(2014, 5, 5, 0, 5)
        scope.$apply()

      it 'shows the proper time in 12-hour format', ->
        expect(picker.getTimeShown()).toEqual("12:05 AM")
        scope.myDate = new Date(2014, 5, 5, 23, 59)
        scope.$apply()
        expect(picker.getTimeShown()).toEqual("11:59 PM")
        scope.myDate = new Date(2014, 5, 5, 0, 0)
        scope.$apply()
        expect(picker.getTimeShown()).toEqual("12:00 AM")

      describe 'and the date object is incremented by 5 minutes from the outside', ->
        beforeEach ->
          scope.myDate = new Date(scope.myDate.setMinutes(10))
          scope.$digest()

        it 'is reflected in the select boxes', ->
          expect(picker.getTimeShown()).toEqual("12:10 AM")

      describe 'and the hour select is set to 9', ->
        beforeEach -> picker.setHourSelect(9)
        it 'changes the displayed time to 9:05', ->
          expect(picker.getTimeShown()).toEqual('9:05 AM')
        it 'changes the model time to 9:05', ->
          scope.$apply()
          expect(scope.myDate.getHours()).toEqual(9)
          expect(scope.myDate.getMinutes()).toEqual(5)

  describe 'a timepicker with am-pm set to false', ->
    beforeEach -> picker = buildTimepicker(new Date(2014, 5, 5, 0, 5), false)

    it 'does not show the am-pm select', ->
      expect($(element).find(".aa-timepicker-ampm").attr('class')).toMatch(/ng-hide/)

    it 'shows the proper time in 24-hour format', ->
      expect(picker.getTimeShown()).toEqual("0:05")
      scope.myDate = new Date(2014, 5, 5, 23, 59)
      scope.$apply()
      expect(picker.getTimeShown()).toEqual("23:59")
      scope.myDate = new Date(2014, 5, 5, 0, 0)
      scope.$apply()
      expect(picker.getTimeShown()).toEqual("0:00")


class TimepickerInterface
  constructor: (element) ->
    @element = $(element)
    @scope = element.scope()

  hourSelect: => $(@element).find(".aa-timepicker-hour")
  minuteSelect: => $(@element).find(".aa-timepicker-minute")
  amPmSelect: => $(@element).find(".aa-timepicker-ampm")

  getHour: =>
    $(@element).find(".aa-timepicker-hour option:selected").text()


  getMinute: =>
    $(@element).find(".aa-timepicker-minute option:selected").text()

  getAmPm: =>
    if $(@element).find(".aa-timepicker-ampm").length
      $(@element).find(".aa-timepicker-ampm option:selected").text()
    else
      null

  setHourSelect: (hour) =>
    $(@element).find(".aa-timepicker-hour option").each((i, opt) =>
      if $(opt).text() == "#{hour}"
        @hourSelect().val($(opt).val())
        @hourSelect().trigger('change')
        return false
    )

  setMinuteSelect: (min) =>
    $(@element).find(".aa-timepicker-minute option").each((i, opt) =>
      if $(opt).text() == "#{min}"
        @minuteSelect().val($(opt).val())
        @minuteSelect().trigger('change')
        return false
    )

  setAmPmSelect: (val) =>
    amPmVals = {
      'AM': '0',
      'PM': '1'
    }
    @amPmSelect().val(amPmVals[val])
    @amPmSelect().trigger('change')
    return

  getTimeShown: =>
    t = "#{@getHour()}:#{@getMinute()}"
    ampm =  @getAmPm()
    t = if ampm then "#{t} #{ampm}" else t
    if t?
      t = t.trim()
      if t == ":"
        t = ""
    t
