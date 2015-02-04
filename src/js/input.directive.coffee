# <input type='date' ng-model='myDate' ng-date-picker-polyfill />
# OR
# <input type='datetime-local' ng-model='myDateTime' ng-date-picker-polyfill />
angular.module('angular-date-picker-polyfill')
  .directive 'input', ->
    {
      restrict: 'E',
      require: '^ngModel',
      link: (scope, elem, attrs, ngModelCtrl) ->
        return unless attrs.type == 'date'
        elem.wrap("<div class='aa-date-input'></div>")

        ngModelCtrl.$parsers.push (viewVal) ->
          console.log('ViewVal:', viewVal, typeof(viewVal))
          console.log('Is ViewVal Date? ', angular.isDate(viewVal))
          viewVal

        ngModelCtrl.$formatters.push (modelVal) ->
          console.log('ModelVal:', modelVal, typeof(modelVal))
          console.log('Is ModelVal Date? ', angular.isDate(modelVal))
          modelVal

    }
