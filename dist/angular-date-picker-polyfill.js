(function() {
  angular.module('angular-date-picker-polyfill', []);

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').directive('aaCalendar', ["aaMonthUtil", "aaDateUtil", "$filter", function(aaMonthUtil, aaDateUtil, $filter) {
    return {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      link: function(scope, elem, attrs, ngModelCtrl) {
        var pullMonthDateFromModel, refreshView;
        scope.dayAbbreviations = ['Su', 'M', 'T', 'W', 'R', 'F', 'S'];
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
          refreshView();
          return scope.$emit('aa:calendar:set-date');
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
      },
      convertToDate: function(val) {
        var d;
        if (angular.isDate(val)) {
          return val;
        } else {
          d = Date.parse(val);
          if (angular.isDate(d)) {
            return d;
          } else {
            return null;
          }
        }
      }
    };
  });

}).call(this);

(function() {
  var linker;

  linker = function(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil) {
    var compileTemplate, init, setupNonInputEvents, setupNonInputValidatorAndFormatter, setupPopupTogglingEvents, setupViewActionMethods;
    init = function() {
      compileTemplate();
      setupViewActionMethods();
      setupPopupTogglingEvents();
      if (elem.prop('tagName') !== 'INPUT' || attrs.type !== 'date') {
        setupNonInputEvents();
        return setupNonInputValidatorAndFormatter();
      }
    };
    setupNonInputValidatorAndFormatter = function() {
      ngModelCtrl.$formatters.unshift(aaDateUtil.convertToDate);
      return ngModelCtrl.$validators.date = function(modelValue, viewValue) {
        return angular.isDate(viewValue);
      };
    };
    compileTemplate = function() {
      var $popup, popupDiv, tmpl;
      elem.wrap("<div class='aa-date-input'></div>");
      tmpl = "<div class='aa-datepicker-popup' data-ng-show='isOpen'>\n  <div class='aa-datepicker-popup-close' data-ng-click='closePopup()'></div>\n  <div data-aa-calendar ng-model='ngModel'></div>\n</div>";
      popupDiv = angular.element(tmpl);
      $popup = $compile(popupDiv)(scope);
      return elem.after($popup);
    };
    setupPopupTogglingEvents = function() {
      var $wrapper, onDocumentClick, wrapperClicked;
      scope.$on('aa:calendar:set-date', function() {
        return scope.closePopup();
      });
      wrapperClicked = false;
      elem.on('focus', function(e) {
        if (!scope.isOpen) {
          return scope.$apply(function() {
            return scope.openPopup();
          });
        }
      });
      $wrapper = elem.parent();
      $wrapper.on('mousedown', function(e) {
        wrapperClicked = true;
        return setTimeout(function() {
          return wrapperClicked = false;
        }, 100);
      });
      elem.on('blur', function(e) {
        if (scope.isOpen && !wrapperClicked) {
          return scope.$apply(function() {
            return scope.closePopup();
          });
        }
      });
      onDocumentClick = function(e) {
        if (scope.isOpen && !wrapperClicked) {
          return scope.$apply(function() {
            return scope.closePopup();
          });
        }
      };
      angular.element(window.document).on('mousedown', onDocumentClick);
      return scope.$on('$destroy', function() {
        elem.off('focus');
        elem.off('blur');
        $wrapper.off('mousedown');
        return document.off('mousedown', onDocumentClick);
      });
    };
    setupNonInputEvents = function() {
      elem.on('click', function(e) {
        if (!scope.isOpen) {
          return scope.$apply(function() {
            return scope.openPopup();
          });
        }
      });
      return scope.$on('$destroy', function() {
        return elem.off('click');
      });
    };
    setupViewActionMethods = function() {
      scope.openPopup = function() {
        return scope.isOpen = true;
      };
      return scope.closePopup = function() {
        return scope.isOpen = false;
      };
    };
    return init();
  };

  angular.module('angular-date-picker-polyfill').directive('aaDateInput', ["$compile", "aaDateUtil", function($compile, aaDateUtil) {
    return {
      restrict: 'A',
      require: 'ngModel',
      scope: {
        ngModel: '='
      },
      link: function(scope, elem, attrs, ngModelCtrl) {
        return linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil);
      }
    };
  }]);

  if (!Modernizr.inputtypes.date) {
    angular.module('angular-date-picker-polyfill').directive('input', ["$compile", "aaDateUtil", function($compile, aaDateUtil) {
      return {
        restrict: 'E',
        require: '?ngModel',
        scope: {
          ngModel: '='
        },
        compile: function(elem, attrs) {
          if (!(attrs.type === 'date' && attrs.ngModel)) {
            return;
          }
          return function(scope, elem, attrs, ngModelCtrl) {
            return linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil);
          };
        }
      };
    }]);
  }

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
