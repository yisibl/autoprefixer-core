autoprefixer = require('../lib/autoprefixer')
Browsers     = require('../lib/browsers')

postcss = require('postcss')
fs      = require('fs')

cleaner      = autoprefixer(browsers: [])
compiler     = autoprefixer(browsers: ['Chrome 25', 'Opera 12'])
filterer     = autoprefixer(browsers: ['Chrome 39', 'Opera 12'])
borderer     = autoprefixer(browsers: ['Safari 4', 'Firefox 3.6'])
keyframer    = autoprefixer(browsers: ['Chrome > 19', 'Opera 12'])
flexboxer    = autoprefixer(browsers: ['Chrome > 19', 'Firefox 21', 'IE 10'])
without3d    = autoprefixer(browsers: ['Opera 12', 'IE > 0'])
uncascader   = autoprefixer(browsers: ['Firefox 15'])
gradienter   = autoprefixer(browsers: ['Chrome 25', 'Opera 12', 'Android 2.3'])
selectorer   = autoprefixer(browsers: ['Chrome 25', 'Firefox > 17', 'IE 10'])
intrinsicer  = autoprefixer(browsers: ['Chrome 25', 'Firefox 22'])
backgrounder = autoprefixer(browsers: ['Firefox 3.6', 'Android 2.3'])
resolutioner = autoprefixer(browsers: ['Firefox 3.6', 'Safari 5', 'Opera 11'])

cascader = autoprefixer
  browsers: ['Chrome > 19', 'Firefox 21', 'IE 10'],
  cascade:  true

prefixer = (name) ->
  if name == 'keyframes'
    keyframer
  else if name == 'border-radius'
    borderer
  else if name == 'vendor-hack' or name == 'value-hack' or name == 'mistakes'
    cleaner
  else if name == 'gradient'
    gradienter
  else if name == 'flexbox' or name == 'flex-rewrite' or name == 'double'
    flexboxer
  else if name == 'selectors' or name == 'placeholder'
    selectorer
  else if name == 'intrinsic' or name == 'multicolumn'
    intrinsicer
  else if name == 'cascade'
    cascader
  else if name == '3d-transform'
    without3d
  else if name == 'background-size'
    backgrounder
  else if name == 'background-clip'
    cleaner
  else if name == 'uncascade'
    uncascader
  else if name == 'example'
    autoprefixer
  else if name == 'viewport'
    flexboxer
  else if name == 'resolution'
    resolutioner
  else if name == 'filter'
    filterer
  else if name == 'crisp-edges'
    intrinsicer
  else if name == 'logical'
    intrinsicer
  else
    compiler

read = (name) ->
  fs.readFileSync(__dirname + "/cases/#{ name }.css").toString()

test = (from, instansce = prefixer(from)) ->
  input  = read(from)
  output = read(from + '.out')
  result = instansce.process(input)
  result.css.should.eql(output)

commons = ['transition', 'values', 'keyframes', 'gradient', 'flex-rewrite',
           'flexbox', 'filter', 'border-image', 'border-radius', 'notes',
           'selectors', 'placeholder', 'fullscreen', 'intrinsic', 'mistakes',
           'custom-prefix', 'cascade', 'double', 'multicolumn', '3d-transform',
           'background-size', 'supports', 'viewport', 'resolution', 'logical']

describe 'autoprefixer()', ->

  it 'sets options', ->
    opts = { browsers: ['chrome 25', 'opera 12'], cascade: false }
    autoprefixer(opts).options.should.eql(opts)

  it 'has default browsers', ->
    autoprefixer.defaults.should.be.an.instanceOf(Array)

describe 'Autoprefixer', ->

  describe 'process()', ->

    it 'prefixes transition',            -> test('transition')
    it 'prefixes values',                -> test('values')
    it 'prefixes @keyframes',            -> test('keyframes')
    it 'prefixes @viewport',             -> test('viewport')
    it 'prefixes selectors',             -> test('selectors')
    it 'prefixes resolution query',      -> test('resolution')
    it 'removes common mistakes',        -> test('mistakes')
    it 'reads notes for prefixes',       -> test('notes')
    it 'keeps vendor-specific hacks',    -> test('vendor-hack')
    it 'keeps values with vendor hacks', -> test('value-hack')
    it 'works with comments',            -> test('comments')
    it 'uses visual cascade',            -> test('cascade')
    it 'works with properties near',     -> test('double')
    it 'checks prefixed in hacks',       -> test('check-down')
    it 'normalize cascade after remove', -> test('uncascade')
    it 'prefix decls in @supports',      -> test('supports')
    it 'saves declaration style',        -> test('style')
    it 'uses control comments',          -> test('disabled')
    it 'has actual example in docs',     -> test('example')

    it 'should irgnore spaces inside values', ->
        css = read('trim')
        flexboxer.process(css).css.should.eql(css)

    it 'removes unnecessary prefixes', ->
      for type in commons
        continue if type == 'cascade'
        continue if type == 'mistakes'
        continue if type == 'flex-rewrite'
        input  = read(type + '.out')
        output = read(type)
        cleaner.process(input).css.should.eql(output)

    it 'does not remove unnecessary prefixes on request', ->
      for type in ['transition', 'values', 'fullscreen']
        css    = read(type + '.out')
        result = autoprefixer(browsers: [], remove: false).process(css)
        result.css.should.eql(css)

    it 'prevents doubling prefixes', ->
      for type in commons
        instance = prefixer(type)

        input  = read(type)
        output = read(type + '.out')
        result = instance.process( instance.process(input) )
        result.css.should.eql(output)

    it 'parses difficult files', ->
      input  = read('syntax')
      result = cleaner.process(input)
      result.css.should.eql(input)

    it 'marks parsing errors', ->
      ( ->
        cleaner.process('a {')
      ).should.throw("<css input>:1:1: Unclosed block")

    it 'shows file name in parse error', ->
      ( ->
        cleaner.process('a {', from: 'a.css')
      ).should.throw(/a.css:1:1: /)

    it 'uses browserslist config', ->
      path   = __dirname + '/cases/config/test.css'
      input  = read('config/test')
      output = read('config/test.out')
      autoprefixer.process(input, from: path).css.should.eql(output)

  describe 'postcss()', ->

    it 'is a PostCSS filter', ->
      postcss( compiler ).process( read('values') ).css
        .should.eql( read('values.out') )

    it 'is a PostCSS filter with default browsers', ->
      postcss( autoprefixer ).process( read('values') ).css
        .should.be.type('string')

  describe 'info()', ->

    it 'returns inspect string', ->
      autoprefixer(browsers: ['chrome 25']).info()
        .should.match(/Browsers:\s+Chrome: 25/)

  describe 'hacks', ->

    it 'changes angle in gradient',     -> test('gradient')
    it 'ignores prefix IE filter',      -> test('filter')
    it 'changes border image syntax',   -> test('border-image')
    it 'supports old Mozilla prefixes', -> test('border-radius')
    it 'supports all flexbox syntaxes', -> test('flexbox')
    it 'supports map flexbox props',    -> test('flex-rewrite')
    it 'supports all placeholders',     -> test('placeholder')
    it 'supports all fullscreens',      -> test('fullscreen')
    it 'supports intrinsic sizing',     -> test('intrinsic')
    it 'supports custom prefixes',      -> test('custom-prefix')
    it 'fixes break-inside property',   -> test('multicolumn')
    it 'ignores some 3D transforms',    -> test('3d-transform')
    it 'supports background-size',      -> test('background-size')
    it 'supports background-clip',      -> test('background-clip')
    it 'supports crisp-edges',          -> test('crisp-edges')
    it 'supports crisp-edges',          -> test('crisp-edges')
    it 'supports logical properties',   -> test('logical')

    it 'ignores values for CSS3PIE props', ->
      input  = read('pie')
      result = compiler.process(input)
      result.css.should.eql(input)
