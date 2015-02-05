linker = (scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil) ->
  # Main Function. Calls all functions below
  init = ->
    compileTemplate()
    setupViewActionMethods()
    setupPopupTogglingEvents()

    if elem.prop('tagName') != 'INPUT' || attrs.type != 'date'
      setupNonInputEvents()
      setupNonInputValidatorAndFormatter()

  # For elments that are not date inputs, do some light formatting
  # and validation
  setupNonInputValidatorAndFormatter = ->
      ngModelCtrl.$formatters.unshift(aaDateUtil.convertToDate)

      ngModelCtrl.$validators.date = (modelValue, viewValue) ->
        angular.isDate(viewValue)


  # Wrap the element in a div, then add the popup div after
  compileTemplate = ->
    elem.wrap("<div class='aa-date-input'></div>")
    tmpl = """
            <div class='aa-datepicker-popup' data-ng-show='isOpen'>
              <div class='aa-datepicker-popup-close' data-ng-click='closePopup()'></div>
              <div data-aa-calendar ng-model='ngModel'></div>
            </div>
           """

    popupDiv = angular.element(tmpl)
    $popup = $compile(popupDiv)(scope)
    elem.after($popup) 

  # Various events need to be created related to opening and closing
  # the popup. They also need to be disabled when the directive
  # is destroyed
  setupPopupTogglingEvents = ->
    # Upon setting the date from the calendar, close the popup
    scope.$on 'aa:calendar:set-date', ->
      scope.closePopup()
    wrapperClicked = false

    # Open on focus
    elem.on 'focus', (e) ->
      unless scope.isOpen
        scope.$apply -> scope.openPopup()

    # Upon click, set a variable so that other
    # events know that the click was intentional
    $wrapper = elem.parent()
    $wrapper.on 'mousedown', (e) ->
      wrapperClicked = true
      setTimeout(
        ->
          wrapperClicked = false
        100
      )

    # On blur (onfocus), close the popup unless
    # there was an intentional click
    elem.on 'blur', (e) ->
      if scope.isOpen && !wrapperClicked
        scope.$apply -> scope.closePopup()

    # If there was a click anywhere else on the
    # page, close the popup
    onDocumentClick = (e) ->
      if scope.isOpen && !wrapperClicked
        scope.$apply -> scope.closePopup()
    angular.element(window.document).on 'mousedown', onDocumentClick

    # Disable events when directive is destroyed
    scope.$on '$destroy', ->
      elem.off 'focus'
      elem.off 'blur'
      $wrapper.off 'mousedown'
      document.off 'mousedown', onDocumentClick

  # Since not all events respond to focus events, add a click event
  setupNonInputEvents = ->
    elem.on 'click', (e) ->
      unless scope.isOpen
        scope.$apply -> scope.openPopup()
    scope.$on '$destroy', -> elem.off 'click'


  # Open and Close methods on the scope
  setupViewActionMethods = ->
    scope.openPopup = ->
      scope.isOpen = true

    scope.closePopup = ->
      scope.isOpen = false


  init()


angular.module('angular-date-picker-polyfill')
  .directive 'aaDateInput', ($compile, aaDateUtil) ->
    {
      restrict: 'A',
      require: 'ngModel',
      scope: {
        ngModel: '='
      },
      link: (scope, elem, attrs, ngModelCtrl) ->
        linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil)
    }


unless Modernizr.inputtypes.date
  angular.module('angular-date-picker-polyfill')
    .directive 'input', ($compile, aaDateUtil) ->
      {
        restrict: 'E',
        require: '?ngModel',
        scope: {
          ngModel: '='
        },
        compile: (elem, attrs) ->
          return unless attrs.type == 'date' && attrs.ngModel
          (scope, elem, attrs, ngModelCtrl) ->
            linker(scope, elem, attrs, ngModelCtrl, $compile, aaDateUtil)
      }
