module.exports = (grunt) ->
  [
    'grunt-contrib-watch'
    'grunt-contrib-compass'
    'grunt-contrib-jade'
    'grunt-contrib-compress'
    'grunt-contrib-connect'
    'grunt-contrib-copy'
    'grunt-inline-css'
    'grunt-contrib-clean'
    'grunt-breakshots'
    'grunt-contrib-imagemin'
  ].forEach(grunt.loadNpmTasks)


  grunt.initConfig

    # config
    pkg: grunt.file.readJSON('package.json')

    config:
      src: 'src' # source files
      build: 'build' # compiled files
      dist: 'dist' # html + img.zip
      export: 'zip' # deliverables (zip, html, images)
      screenshots: 'screenshots' # responsive screenshots


    # ---
    # watch files
    watch:
      sass:
        files: ['<%= config.src %>/sass/**/*.scss']
        tasks: ['build']

      jade:
        files: ['<%= config.src %>/**/*.jade']
        tasks: ['build']

      data:
        files: ['data.json']
        tasks: ['build']

      images:
        files: ['<%= config.src %>/img/*']
        tasks: ['imagemin']


    # ---
    # devserver
    connect:
      server:
        options:
          port: 8000
          base: '<%= config.build %>'

      tmp:
        options:
          port: 8000
          base: ''


    # ---
    # clean
    clean:
      build: ['<%= config.build %>/**/*']
      dist: ['<%= config.dist %>/**/*']
      export: ['<%= config.export %>/**/*']


    # ---
    # copy
    copy:

      # copy html files to dist
      dist: 
        files: 
          [
            {
              expand: true
              src: ['**/*.html']
              dest: '<%= config.dist %>/'
              cwd: '<%= config.build %>/'
            }
          ]


    # ---
    # compress
    compress:

      # compress img.zip
      dist:
        options:
          archive: "<%= config.dist %>/img.zip"
          mode: 'zip'
        files: [
          {
            expand: true
            src: ['img/**']
            dest: ''
            cwd: '<%= config.build %>'
          }
        ]


      # create zip file 'packagename<date><time>.zip'
      export:
        options:
          mode: 'zip'
          archive: """<%= config.export %>/<%= pkg.name %> (<%= grunt.template.date(new Date(), 'yyyymmddHHMMss') %>).zip"""
          
        files: [

          # add index.html to zip file
          {
            expand: true
            src: ['**/*.html']
            dest: ''
            cwd: '<%= config.build %>'
          }

          # add images folder to zip file
          {
            expand: true
            src: 'img/**'
            dest: ''
            cwd: '<%= config.build %>'
          }
        ]


    # ---
    # jade
    jade:
      build:
        options:
          pretty: true
          data: 
            data: grunt.file.readJSON('data.json') # set of variables
            css: grunt.file.read('build/css/styles.css') # inline head css
            responsive_css: grunt.file.read('build/css/responsive.css') # inline head css for responsiveness

        files: [
          expand: true
          pretty: true
          src: ['**/*.jade', '!**/_*.jade']
          dest: '<%= config.build %>/'
          ext: '.html'
          cwd: '<%= config.src %>/'
        ]


    # ---
    # compass
    compass: 
      dev:
        options:
          sassDir: '<%= config.src %>/sass/'
          cssDir: '<%= config.build %>/css/'
          relativeAssets: false
          noLineComments: true
          force: true
          outputStyle: 'compressed'


    # ---
    # inline css
    inlinecss:
      export:
        options:
          removeStyleTags: false
        files: [
          {
            expand: true
            src: '**/*.html'
            dest: '<%= config.build %>'
            cwd: '<%= config.build %>'
          }
        ]


    # ---
    # screenshots
    breakshots:
      github:
        options:
          breakpoints: [320, 640]
        files: [
          {
            src: ['build/*.html']
            dest: '<%= config.screenshots %>/'
          }
        ]


    # ---
    # image min
    imagemin:
      dist:
        files: [
          expand: true
          cwd: '<%= config.src %>'
          src: ['img/**/*.{png,jpg,gif}']
          dest: '<%= config.build %>'
        ]
          


  # task
  grunt.registerTask('default', ['connect:server', 'watch'])
  grunt.registerTask('build', ['clean:build', 'clean:dist', 'compass', 'jade', 'inlinecss', 'imagemin'])
  grunt.registerTask('export', ['copy:dist', 'compress:dist', 'compress:export'])

  grunt.registerTask('screenshot', ['connect:tmp','breakshots:github'])
