axis         = require 'axis-css'
autoprefixer = require 'autoprefixer-stylus'
rupture      = require 'rupture'

module.exports =
  ignores: ['readme.md', '**/layout.*', '**/_*', '.gitignore', '**/.*.sw*']

  stylus:
    use: [axis(), autoprefixer(), rupture()]
