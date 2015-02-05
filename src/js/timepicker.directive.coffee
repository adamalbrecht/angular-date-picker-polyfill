# <div ng-model='myDate' aa-timepicker></div>
angular.module('angular-date-picker-polyfill')
  .directive 'aaTimepicker', (aaTimeUtil, aaDateUtil) ->
    {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      scope: {},
      link: (scope, elem, attrs, ngModelCtrl) ->

        init = ->
          setupSelectOptions()
          resetToNull()

        setupSelectOptions = ->
          scope.useAmPm = if attrs.useAmPm? then (attrs.useAmPm == true || attrs.useAmPm == 'true') else true
          scope.hourOptions = if scope.useAmPm then [1..12] else [0..23]
          scope.minuteOptions = [0..59]
          scope.amPmOptions = ['AM', 'PM']

        resetToNull = ->
          scope.hour = null
          scope.minute = null
          scope.amPm = null

        ngModelCtrl.$render = ->
          pullTimeFromModel()

        pullTimeFromModel = ->
          if angular.isDate(ngModelCtrl.$viewValue)
            d = angular.copy(ngModelCtrl.$viewValue)
            [scope.hour, scope.minute, scope.amPm] = aaTimeUtil.getMinuteAndHourFromDate(d, scope.useAmPm)
          else
            resetToNull()

        scope.setTimeFromFields = ->
          if scope.hour? && !scope.minute?
            scope.minute = 0
          if scope.hour? && scope.useAmPm && !scope.amPm?
            scope.amPm = 'AM'
          return unless scope.hour? && scope.minute? && (!scope.useAmPm || scope.amPm?)
          if ngModelCtrl.$viewValue? && angular.isDate(ngModelCtrl.$viewValue)
            d = new Date(ngModelCtrl.$viewValue)
          else
            d = aaDateUtil.todayStart()
          aaTimeUtil.applyTimeValuesToDateObject([scope.hour, parseInt(scope.minute), scope.amPm], d)
          ngModelCtrl.$setViewValue(d)

        init()


      template: """
                  <div class='aa-timepicker'>
                    <select
                      class='aa-timepicker-hour'
                      ng-model='hour'
                      ng-options='hour as hour for hour in ::hourOptions'
                      ng-change='setTimeFromFields()'>
                    </select>
                    <select
                      class='aa-timepicker-minute'
                      ng-model='minute'
                      ng-options="min as ((min < 10) ? ('0' + min) : ('' + min)) for min in ::minuteOptions"
                      ng-change='setTimeFromFields()'>
                    </select>
                    <select
                      class='aa-timepicker-ampm'
                      ng-show='useAmPm'
                      ng-model='amPm'
                      ng-options='v for v in ::amPmOptions'
                      ng-change='setTimeFromFields()'>
                    </select>
                  </div>
                """
    }
