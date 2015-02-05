module.exports = (config) ->
  config.set
    autoWatch: true
    frameworks: ['jasmine']
    browsers: ['PhantomJS']
    preprocessors: {
      '**/*.coffee': ['coffee'],
    },
    coffeePreprocessor: {
      options: {
        sourceMap: false
      }
      transformPath: (path) -> path.replace(/\.js$/, '.coffee')
    }
    reporters: ['progress', 'osx'],
    files: [
      "vendor/bower/modernizr/modernizr.js",
      "vendor/bower/jquery/dist/jquery.min.js",
      "vendor/bower/lodash/lodash.js",
      "vendor/bower/angular/angular.js",
      "vendor/bower/angular-mocks/angular-mocks.js",
      "src/js/**/*.coffee"
    ]
