const gulp = require('gulp')
const ts = require('gulp-typescript')
const del = require('del')

gulp.task('es', function () {
  const tsProject = ts.createProject('./tsconfig.json', {
    module: 'esnext',
  })
  return gulp
    .src([
      'src/**/*+(.ts|.tsx)',
      'package.json',
      '!src/**/*.stories.tsx',
      '!src/**/*.stories.mdx',
      '!src/**/*.stories.prod.tsx',
      '!src/**/*.stories.prod.mdx',
    ])
    .pipe(tsProject())
    .pipe(gulp.dest('es'))
})

gulp.task('lib', function () {
  const tsProject = ts.createProject('./tsconfig.json', {
    module: 'commonjs',
  })
  return gulp
    .src([
      'src/**/*+(.ts|.tsx)',
      'package.json',
      '!src/**/*.stories.tsx',
      '!src/**/*.stories.mdx',
      '!src/**/*.stories.prod.tsx',
      '!src/**/*.stories.prod.mdx',
    ])
    .pipe(tsProject())
    .pipe(gulp.dest('lib'))
})

gulp.task('copyLess', function () {
  return gulp
    .src(['src/**/*.less'])
    .pipe(gulp.dest('lib'))
    .pipe(gulp.dest('es'))
})

gulp.task('assets', function () {
  return gulp.src(['src/**/*.png']).pipe(gulp.dest('lib')).pipe(gulp.dest('es'))
})

gulp.task('clean', function () {
  return del(['es', 'lib'])
})

gulp.task(
  'default',
  gulp.series('clean', gulp.parallel(['es', 'lib', 'copyLess', 'assets']))
)

gulp.task('watch', function () {
  gulp.watch(
    ['src/**/*+(.ts|.tsx)', '!src/**/*.stories.tsx'],
    gulp.parallel(['es', 'lib'])
  )
  gulp.watch(['src/**/*.less'], gulp.parallel(['copyLess']))
})
