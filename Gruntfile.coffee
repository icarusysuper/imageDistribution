module.exports = (grunt)->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        # copy: 
        #     build:
        #         cwd: './'
        #         src: ['**', '!node_modules/**/*', '!**/*.styl', '!**/*.coffee', '!**/*.jade']
        #         dest: '.build'
        #         expand: true

        copy: 
            build:
                cwd: './'
                src: ['**/*', '.gitignore', '!node_modules', '!node_modules/**/*', '!**/*.coffee']
                dest: '.build'
                expand: true

        clean:
            build:
                src: [
                    '.build/**/*'
                    '!.build/node_modules'
                    '!.build/node_modules/**/*'
                    '!.build/public'
                    '!.build/public/user_data'
                    '!.build/public/user_data/**/*'
                    '!.build/.git'
                    '!.build/.gitignore'
                ]

        stylus:
            build:
                options:
                    compress: false
                files: [
                    expand: true;
                    src: ['**/*.styl']
                    dest: '.build'
                    ext: '.css'
                ]

        autoprefixer: 
            build: 
                expand: true
                cwd: '.build'
                src: ['**/*.css']
                dest: '.build'

        coffee: 
             build: 
                expand: true
                ext: '.js'
                dest: '.build'
                src: ['**/*.coffee', '!Gruntfile.coffee']

        jade: 
            build: 
                expand: true
                ext: '.html'
                dest: '.build'
                src: ['**/*.jade']

        watch: 
            scripts: 
                files: ['**/*.coffee', '!Gruntfile.coffee']
                tasks: ['scripts']
            copy:
                files: ['**/*.jade', '**/*.styl', 'package.json', 'test/mocha.opts']
                tasks: ['copy']
            # stylesheets:
            #     files: ['**/*.styl']
            #     tasks: ['stylesheets']
            # jade:
            #     files: ['**/*.jade']
            #     tasks: ['jade']

        grunt.loadNpmTasks 'grunt-contrib-copy' 
        grunt.loadNpmTasks 'grunt-contrib-clean'
        # grunt.loadNpmTasks 'grunt-contrib-stylus'
        # grunt.loadNpmTasks 'grunt-autoprefixer'
        grunt.loadNpmTasks 'grunt-contrib-coffee'
        # grunt.loadNpmTasks 'grunt-contrib-jade'
        grunt.loadNpmTasks 'grunt-contrib-watch'

        # grunt.registerTask 'test-copy', 'copy files to .build', ['copy']
        # grunt.registerTask 'test-clean', 'clean files', ['clean']
        # grunt.registerTask 'stylesheets', 'Compiles the stylus to css.', ['stylus', 'autoprefixer']
        grunt.registerTask 'scripts', 'Compiles coffeescript to javascript', ['coffee']
        grunt.registerTask 'build', 'build project', ['clean', 'copy', 'coffee', 'watch']
