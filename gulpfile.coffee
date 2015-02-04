gulp = require('gulp')
$ = require('gulp-load-plugins')()

packageName = 'angular-date-picker-polyfill'

gulp.task 'scripts', ->
  gulp.src(['src/js/**/*.coffee', '!src/js/**/*.spec.coffee'])
    .pipe($.plumber({errorHandler: $.util.log}))
    .pipe($.coffee())
    .pipe($.ngAnnotate())
    .pipe($.concat("#{packageName}.js"))
    .pipe(gulp.dest('dist'))
    .pipe($.uglify())
    .pipe($.rename({suffix: '.min'}))
    .pipe(gulp.dest('dist'))

gulp.task 'stylesheets', ->
  gulp.src(['src/css/**/*.scss'])
    .pipe($.plumber({errorHandler: $.util.log}))
    .pipe($.sass({
      outputStyle: 'nested',
      errLogToConsole: true
    }))
    .pipe($.rename({prefix: packageName + "-"}))
    .pipe(gulp.dest('dist'))
    .pipe($.minifyCss())
    .pipe($.rename({suffix: '.min'}))
    .pipe(gulp.dest('dist'))

gulp.task 'watch', ->
  gulp.watch('src/js/**/*.coffee', ['scripts'])
  gulp.watch('src/css/**/*.scss', ['stylesheets'])

gulp.task 'clean', ->
  return gulp.src(["dist"], {read: false})
    .pipe($.rimraf({force: true}))

gulp.task 'compile', ['clean'], ->
  gulp.start('scripts', 'stylesheets')

gulp.task 'dev', ['compile'], ->
  gulp.start('watch')
