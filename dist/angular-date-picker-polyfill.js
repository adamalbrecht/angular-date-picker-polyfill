(function() {
  angular.module('angular-date-picker-polyfill', []);

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').directive('aaCalendar', ["aaMonthUtil", "aaDateUtil", "$filter", function(aaMonthUtil, aaDateUtil, $filter) {
    return {
      restrict: 'A',
      replace: true,
      require: '^ngModel',
      link: function(scope, elem, attrs, ngModelCtrl) {
        var pullMonthDateFromModel, refreshView;
        scope.dayAbbreviations = ['S', 'M', 'T', 'W', 'R', 'F', 'S'];
        scope.monthArray = [[]];
        scope.monthDate = null;
        scope.selected = null;
        ngModelCtrl.$render = function() {
          scope.selected = ngModelCtrl.$viewValue;
          pullMonthDateFromModel();
          return refreshView();
        };
        pullMonthDateFromModel = function() {
          var d;
          if (angular.isDate(ngModelCtrl.$viewValue)) {
            d = angular.copy(ngModelCtrl.$viewValue);
          } else {
            d = new Date();
          }
          d.setDate(1);
          return scope.monthDate = d;
        };
        refreshView = function() {
          return scope.monthArray = aaMonthUtil.generateMonthArray(scope.monthDate.getFullYear(), scope.monthDate.getMonth(), ngModelCtrl.$viewValue);
        };
        scope.setDate = function(d) {
          ngModelCtrl.$setViewValue(d);
          if (!aaDateUtil.dateObjectsAreEqualToMonth(d, scope.monthDate)) {
            pullMonthDateFromModel();
          }
          return refreshView();
        };
        scope.setToToday = function() {
          return scope.setDate(new Date());
        };
        return scope.incrementMonths = function(num) {
          scope.monthDate.setMonth(scope.monthDate.getMonth() + num);
          return refreshView();
        };
      },
      template: "<div class='aa-cal'>\n  <div class='aa-cal-controls'>\n    <span ng-click='incrementMonths(-12)' class='aa-cal-btn aa-cal-prev-year'></span>\n    <span ng-click='incrementMonths(-1)' class='aa-cal-btn aa-cal-prev-month'></span>\n    <span ng-click='setToToday()' class='aa-cal-btn aa-cal-set-to-today'></span>\n    <strong class='aa-cal-month-name' ng-bind=\"monthDate | date:'MMMM yyyy'\"></strong>\n    <span ng-click='incrementMonths(12)' class='aa-cal-btn aa-cal-next-year'></span>\n    <span ng-click='incrementMonths(1)' class='aa-cal-btn aa-cal-next-month'></span>\n  </div>\n  <table class='aa-cal-month'>\n    <thead>\n      <tr><th ng-repeat='abbr in ::dayAbbreviations track by $index' ng-bind='abbr'></th></tr>\n    </thead>\n    <tbody>\n      <tr ng-repeat='week in monthArray'>\n        <td\n          ng-repeat='day in week'\n          ng-class=\"{'aa-cal-today': day.isToday, 'aa-cal-other-month': day.isOtherMonth, 'aa-cal-selected': day.isSelected, 'aa-cal-disabled': day.isDisabled}\"\n          ng-click='setDate(day.date)'>\n            <span ng-bind=\"day.date | date:'d'\"></span>\n        </td>\n      </tr>\n    </tbody>\n  </table>\n</div>"
    };
  }]);

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').factory('aaDateUtil', function() {
    return {
      dateObjectsAreEqualToDay: function(d1, d2) {
        if (!(angular.isDate(d1) && angular.isDate(d2))) {
          return false;
        }
        return (d1.getFullYear() === d2.getFullYear()) && (d1.getMonth() === d2.getMonth()) && (d1.getDate() === d2.getDate());
      },
      dateObjectsAreEqualToMonth: function(d1, d2) {
        if (!(angular.isDate(d1) && angular.isDate(d2))) {
          return false;
        }
        return (d1.getFullYear() === d2.getFullYear()) && (d1.getMonth() === d2.getMonth());
      }
    };
  });

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').directive('input', function() {
    return {
      restrict: 'E',
      require: '^ngModel',
      link: function(scope, elem, attrs, ngModelCtrl) {
        if (attrs.type !== 'date') {
          return;
        }
        elem.wrap("<div class='aa-date-input'></div>");
        ngModelCtrl.$parsers.push(function(viewVal) {
          console.log('ViewVal:', viewVal, typeof viewVal);
          console.log('Is ViewVal Date? ', angular.isDate(viewVal));
          return viewVal;
        });
        return ngModelCtrl.$formatters.push(function(modelVal) {
          console.log('ModelVal:', modelVal, typeof modelVal);
          console.log('Is ModelVal Date? ', angular.isDate(modelVal));
          return modelVal;
        });
      }
    };
  });

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').factory('aaMonthUtil', ["aaDateUtil", function(aaDateUtil) {
    return {
      numberOfDaysInMonth: function(year, month) {
        return [31, ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
      },
      generateMonthArray: function(year, month, selected) {
        var arr, d, dayIndex, endDate, obj, offset, today, weekNum, _i;
        if (selected == null) {
          selected = null;
        }
        d = new Date(year, month, 1);
        today = new Date();
        endDate = new Date(year, month, this.numberOfDaysInMonth(year, month));
        offset = d.getDay();
        d.setDate(d.getDate() + (offset * -1));
        arr = [];
        weekNum = 0;
        while (d <= endDate) {
          arr.push([]);
          for (dayIndex = _i = 0; _i <= 6; dayIndex = ++_i) {
            obj = {
              date: angular.copy(d),
              isToday: aaDateUtil.dateObjectsAreEqualToDay(d, today),
              isSelected: selected && aaDateUtil.dateObjectsAreEqualToDay(d, selected) ? true : false,
              isOtherMonth: d.getMonth() !== month
            };
            arr[weekNum].push(obj);
            d.setDate(d.getDate() + 1);
          }
          weekNum += 1;
        }
        return arr;
      }
    };
  }]);

}).call(this);
