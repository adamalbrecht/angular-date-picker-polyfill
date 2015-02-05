# <div ng-date-picker-polyfill-calendar></div>
angular.module('angular-date-picker-polyfill')
  .directive 'aaCalendar', (aaMonthUtil, aaDateUtil, $filter) ->
    {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      link: (scope, elem, attrs, ngModelCtrl) ->
        scope.dayAbbreviations = ['Su', 'M', 'T', 'W', 'R', 'F', 'S']
        # Nested array of the dates in the month
        scope.monthArray = [[]]
        # Date representing the calendar month shown
        scope.monthDate = null
        scope.selected = null

        # ngModelController Communication
        # ============================================
        ngModelCtrl.$render = ->
          scope.selected = ngModelCtrl.$viewValue
          pullMonthDateFromModel()
          refreshView()

        # View / Scope Helpers
        # ============================================
        pullMonthDateFromModel = ->
          if angular.isDate(ngModelCtrl.$viewValue)
            d = angular.copy(ngModelCtrl.$viewValue)
          else
            d = new Date()
          d.setDate(1)
          scope.monthDate = d


        refreshView = ->
          scope.monthArray = aaMonthUtil.generateMonthArray(
            scope.monthDate.getFullYear(),
            scope.monthDate.getMonth(),
            ngModelCtrl.$viewValue
          )

        # View Actions
        # ============================================
        scope.setDate = (d) ->
          ngModelCtrl.$setViewValue(d)
          unless aaDateUtil.dateObjectsAreEqualToMonth(d, scope.monthDate)
            pullMonthDateFromModel()
          refreshView()
          scope.$emit('aa:calendar:set-date')

        scope.setToToday = ->
          scope.setDate(new Date())

        scope.incrementMonths = (num) ->
          scope.monthDate.setMonth(scope.monthDate.getMonth() + num)
          refreshView()

      template: """
                  <div class='aa-cal'>
                    <div class='aa-cal-controls'>
                      <span ng-click='incrementMonths(-12)' class='aa-cal-btn aa-cal-prev-year'></span>
                      <span ng-click='incrementMonths(-1)' class='aa-cal-btn aa-cal-prev-month'></span>
                      <span ng-click='setToToday()' class='aa-cal-btn aa-cal-set-to-today'></span>
                      <strong class='aa-cal-month-name' ng-bind="monthDate | date:'MMMM yyyy'"></strong>
                      <span ng-click='incrementMonths(12)' class='aa-cal-btn aa-cal-next-year'></span>
                      <span ng-click='incrementMonths(1)' class='aa-cal-btn aa-cal-next-month'></span>
                    </div>
                    <table class='aa-cal-month'>
                      <thead>
                        <tr><th ng-repeat='abbr in ::dayAbbreviations track by $index' ng-bind='abbr'></th></tr>
                      </thead>
                      <tbody>
                        <tr ng-repeat='week in monthArray'>
                          <td
                            ng-repeat='day in week'
                            ng-class="{'aa-cal-today': day.isToday, 'aa-cal-other-month': day.isOtherMonth, 'aa-cal-selected': day.isSelected, 'aa-cal-disabled': day.isDisabled}"
                            ng-click='setDate(day.date)'>
                              <span ng-bind="day.date | date:'d'"></span>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                """
    }
