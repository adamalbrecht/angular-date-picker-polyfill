(function() {
  angular.module('angular-date-picker-polyfill', []);

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').directive('aaCalendar', ["aaMonthUtil", "aaDateUtil", "$filter", function(aaMonthUtil, aaDateUtil, $filter) {
    return {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      scope: {},
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
          var c;
          c = angular.isDate(ngModelCtrl.$viewValue) ? angular.copy(ngModelCtrl.$viewValue) : aaDateUtil.todayStart();
          c.setYear(d.getFullYear());
          c.setMonth(d.getMonth());
          c.setDate(d.getDate());
          ngModelCtrl.$setViewValue(c);
          if (!aaDateUtil.dateObjectsAreEqualToMonth(d, scope.monthDate)) {
            pullMonthDateFromModel();
          }
          refreshView();
          return scope.$emit('aa:calendar:set-date');
        };
        scope.setToToday = function() {
          return scope.setDate(aaDateUtil.todayStart());
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
      },
      todayStart: function() {
        var d;
        d = new Date();
        d.setHours(0);
        d.setMinutes(0);
        d.setSeconds(0);
        d.setMilliseconds(0);
        return d;
      }
    };
  });

}).call(this);

(function() {
  var linker;

  linker = function(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil, includeTimepicker) {
    var compileTemplate, init, setupNonInputEvents, setupNonInputValidatorAndFormatter, setupPopupTogglingEvents, setupViewActionMethods;
    if (includeTimepicker == null) {
      includeTimepicker = false;
    }
    init = function() {
      compileTemplate();
      setupViewActionMethods();
      setupPopupTogglingEvents();
      if (elem.prop('tagName') !== 'INPUT' || (attrs.type !== 'date' && attrs.type !== 'datetime-local')) {
        setupNonInputEvents();
        return setupNonInputValidatorAndFormatter();
      }
    };
    setupNonInputValidatorAndFormatter = function() {
      ngModelCtrl.$formatters.unshift(aaDateUtil.convertToDate);
      if (includeTimepicker) {
        return ngModelCtrl.$validators['datetime-local'] = function(modelValue, viewValue) {
          return !viewValue || angular.isDate(viewValue);
        };
      } else {
        return ngModelCtrl.$validators.date = function(modelValue, viewValue) {
          return !viewValue || angular.isDate(viewValue);
        };
      }
    };
    compileTemplate = function() {
      var $popup, popupDiv, tmpl, useAmPm;
      elem.wrap("<div class='aa-date-input'></div>");
      tmpl = "<div class='aa-datepicker-popup' data-ng-show='isOpen'>\n  <div class='aa-datepicker-popup-close' data-ng-click='closePopup()'></div>\n  <div data-aa-calendar ng-model='ngModel'></div>";
      if (includeTimepicker) {
        useAmPm = attrs.useAmPm != null ? attrs.useAmPm === true || attrs.useAmPm === 'true' : true;
        tmpl += "<div data-aa-timepicker use-am-pm='" + useAmPm + "' ng-model='ngModel'></div>";
      }
      tmpl += "</div>";
      popupDiv = angular.element(tmpl);
      $popup = $compile(popupDiv)(scope);
      return elem.after($popup);
    };
    setupPopupTogglingEvents = function() {
      var $wrapper, onDocumentClick, wrapperClicked;
      scope.$on('aa:calendar:set-date', function() {
        if (!includeTimepicker) {
          return scope.closePopup();
        }
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
        return angular.element(window.document).off('mousedown', onDocumentClick);
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
        return linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil, false);
      }
    };
  }]);

  angular.module('angular-date-picker-polyfill').directive('aaDateTimeInput', ["$compile", "aaDateUtil", function($compile, aaDateUtil) {
    return {
      restrict: 'A',
      require: 'ngModel',
      scope: {
        ngModel: '='
      },
      link: function(scope, elem, attrs, ngModelCtrl) {
        return linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil, true);
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
          if (!((attrs.ngModel != null) && (attrs.type === 'date' || attrs.type === 'datetime-local'))) {
            return;
          }
          return function(scope, elem, attrs, ngModelCtrl) {
            return linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil, attrs.type === 'datetime-local');
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

(function() {
  angular.module('angular-date-picker-polyfill').factory('aaTimeUtil', function() {
    return {
      getMinuteAndHourFromDate: function(d, useAmPmHours) {
        var amPm, h, m;
        if (useAmPmHours == null) {
          useAmPmHours = true;
        }
        if (!angular.isDate(d)) {
          return null;
        }
        h = d.getHours();
        amPm = null;
        if (useAmPmHours) {
          switch (false) {
            case h !== 0:
              h = 12;
              amPm = 'AM';
              break;
            case h !== 12:
              amPm = 'PM';
              break;
            case !(h > 12):
              h = h - 12;
              amPm = 'PM';
          }
        }
        m = d.getMinutes();
        return [h, m, amPm];
      },
      applyTimeValuesToDateObject: function(timeValues, d) {
        var amPm, hour, minute;
        hour = timeValues[0], minute = timeValues[1], amPm = timeValues[2];
        d.setMinutes(minute);
        if (amPm === 'AM') {
          d.setHours(hour === 12 ? 0 : hour);
        } else if (amPm === 'PM' && hour === 12) {
          d.setHours(12);
        } else if (amPm === 'PM' && hour !== 12) {
          d.setHours(hour + 12);
        } else {
          d.setHours(hour);
        }
        return d;
      }
    };
  });

}).call(this);

(function() {
  angular.module('angular-date-picker-polyfill').directive('aaTimepicker', ["aaTimeUtil", "aaDateUtil", function(aaTimeUtil, aaDateUtil) {
    return {
      restrict: 'A',
      replace: true,
      require: 'ngModel',
      scope: {},
      link: function(scope, elem, attrs, ngModelCtrl) {
        var init, pullTimeFromModel, resetToNull, setupSelectOptions;
        init = function() {
          setupSelectOptions();
          return resetToNull();
        };
        setupSelectOptions = function() {
          var _i, _j, _results, _results1;
          scope.useAmPm = attrs.useAmPm != null ? attrs.useAmPm === true || attrs.useAmPm === 'true' : true;
          scope.hourOptions = scope.useAmPm ? [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] : (function() {
            _results = [];
            for (_i = 0; _i <= 23; _i++){ _results.push(_i); }
            return _results;
          }).apply(this);
          scope.minuteOptions = (function() {
            _results1 = [];
            for (_j = 0; _j <= 59; _j++){ _results1.push(_j); }
            return _results1;
          }).apply(this);
          return scope.amPmOptions = ['AM', 'PM'];
        };
        resetToNull = function() {
          scope.hour = null;
          scope.minute = null;
          return scope.amPm = null;
        };
        ngModelCtrl.$render = function() {
          return pullTimeFromModel();
        };
        pullTimeFromModel = function() {
          var d, _ref;
          if (angular.isDate(ngModelCtrl.$viewValue)) {
            d = angular.copy(ngModelCtrl.$viewValue);
            return _ref = aaTimeUtil.getMinuteAndHourFromDate(d, scope.useAmPm), scope.hour = _ref[0], scope.minute = _ref[1], scope.amPm = _ref[2], _ref;
          } else {
            return resetToNull();
          }
        };
        scope.setTimeFromFields = function() {
          var d;
          if ((scope.hour != null) && (scope.minute == null)) {
            scope.minute = 0;
          }
          if ((scope.hour != null) && scope.useAmPm && (scope.amPm == null)) {
            scope.amPm = 'AM';
          }
          if (!((scope.hour != null) && (scope.minute != null) && (!scope.useAmPm || (scope.amPm != null)))) {
            return;
          }
          if ((ngModelCtrl.$viewValue != null) && angular.isDate(ngModelCtrl.$viewValue)) {
            d = new Date(ngModelCtrl.$viewValue);
          } else {
            d = aaDateUtil.todayStart();
          }
          aaTimeUtil.applyTimeValuesToDateObject([scope.hour, parseInt(scope.minute), scope.amPm], d);
          return ngModelCtrl.$setViewValue(d);
        };
        return init();
      },
      template: "<div class='aa-timepicker'>\n  <select\n    tabindex='-1'\n    class='aa-timepicker-hour'\n    ng-model='hour'\n    ng-options='hour as hour for hour in ::hourOptions'\n    ng-change='setTimeFromFields()'>\n  </select>\n  <select\n    tabindex='-1'\n    class='aa-timepicker-minute'\n    ng-model='minute'\n    ng-options=\"min as ((min < 10) ? ('0' + min) : ('' + min)) for min in ::minuteOptions\"\n    ng-change='setTimeFromFields()'>\n  </select>\n  <select\n    tabindex='-1'\n    class='aa-timepicker-ampm'\n    ng-show='useAmPm'\n    ng-model='amPm'\n    ng-options='v for v in ::amPmOptions'\n    ng-change='setTimeFromFields()'>\n  </select>\n</div>"
    };
  }]);

}).call(this);
