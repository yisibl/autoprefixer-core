browsers = require('./browsers')

# Sort browsers
sort = (array) ->
  array.sort (a, b) ->
    a = a.split(' ')
    b = b.split(' ')
    if a[0] > b[0]
      1
    else if a[0] < b[0]
      -1
    else
      parseFloat(a[1]) - parseFloat(b[1])

# Convert Can I Use data
feature = (data, opts, callback) ->
  [callback, opts] = [opts, { }] unless callback

  match = opts.match || /\sx($|\s)/
  need  = []

  for browser, versions of data.stats
    for interval, support of versions
      for version in interval.split('-')
        if browsers[browser] and support.match(match)
          version = version.replace(/\.0$/, '')
          need.push(browser + ' ' + version)

  callback(sort(need))

# Select only special browsers
map = (browsers, callback) ->
  for browser in browsers
    [name, version] = browser.split(' ')
    version = parseFloat(version)
    callback(browser, name, version)

# Select only special browsers
filter = (browsers, callback) ->
  browsers.filter (browser) ->
    [name, version] = browser.split(' ')
    version = parseFloat(version)
    callback(name, version)

# Add data for all properties
result = { }
prefix = (names..., data) ->
  for name in names
    if result[name]
      result[name].browsers = sort(result[name].browsers.concat(data.browsers))
    else
      result[name] = { }
      for i of data
        result[name][i] = data[i]

module.exports = result

# Border Radius
feature require('caniuse-db/features-json/border-radius'), (browsers) ->
  prefix 'border-radius', 'border-top-left-radius', 'border-top-right-radius',
         'border-bottom-right-radius', 'border-bottom-left-radius',
          mistakes:   ['-ms-', '-o-']
          transition: true
          browsers:   browsers

# Box Shadow
feature require('caniuse-db/features-json/css-boxshadow'), (browsers) ->
  prefix 'box-shadow',
          transition: true
          browsers:   browsers

# Animation
feature require('caniuse-db/features-json/css-animation'), (browsers) ->
  prefix 'animation', 'animation-name', 'animation-duration',
         'animation-delay', 'animation-direction', 'animation-fill-mode',
         'animation-iteration-count', 'animation-play-state',
         'animation-timing-function', '@keyframes',
          browsers: browsers

# Transition
feature require('caniuse-db/features-json/css-transitions'), (browsers) ->
  prefix 'transition', 'transition-property', 'transition-duration',
         'transition-delay', 'transition-timing-function',
          mistakes: ['-ms-']
          browsers: browsers

# Transform 2D
feature require('caniuse-db/features-json/transforms2d'), (browsers) ->
  prefix 'transform', 'transform-origin',
          transition: true
          browsers:   browsers

# Transform 3D
feature require('caniuse-db/features-json/transforms3d'), (browsers) ->
  prefix 'perspective', 'perspective-origin',
          transition: true
          browsers:   browsers

  prefix 'transform-style', 'backface-visibility',
          browsers: browsers

# Gradients
feature require('caniuse-db/features-json/css-gradients'), (browsers) ->
  browsers = map browsers, (browser, name, version) ->
    if name == 'android' and version < 4 or
       name == 'ios_saf' and version < 5 or
       name == 'safari'  and version < 5.1
      browser + ' old'
    else
      browser

  prefix 'linear-gradient', 'repeating-linear-gradient',
         'radial-gradient', 'repeating-radial-gradient',
          props:    ['background', 'background-image', 'border-image',
                     'list-style', 'list-style-image', 'content']
          mistakes: ['-ms-']
          browsers: browsers

# Box sizing
feature require('caniuse-db/features-json/css3-boxsizing'), (browsers) ->
  prefix 'box-sizing',
          browsers: browsers

# Filter Effects
feature require('caniuse-db/features-json/css-filters'), (browsers) ->
  prefix 'filter',
          transition: true
          browsers:   browsers

# Multicolumns
feature require('caniuse-db/features-json/multicolumn'), (browsers) ->
  prefix 'columns', 'column-width', 'column-gap',
         'column-rule', 'column-rule-color', 'column-rule-width',
          transition: true
          browsers:   browsers

  prefix 'column-count', 'column-rule-style', 'column-span', 'column-fill',
         'break-before', 'break-after', 'break-inside',
          browsers:   browsers

# User select
feature require('caniuse-db/features-json/user-select-none'), (browsers) ->
  prefix 'user-select',
          browsers: browsers

# Flexible Box Layout
flexbox = require('caniuse-db/features-json/flexbox')

feature flexbox, match: /y\sx|a\sx\s#2/, (browsers) ->
  prefix 'display-flex', 'inline-flex',
          props:  ['display']
          browsers: browsers
  prefix 'flex', 'flex-grow', 'flex-shrink', 'flex-basis',
          transition: true
          browsers:   browsers
  prefix 'flex-direction', 'flex-wrap', 'flex-flow', 'justify-content',
         'order', 'align-items', 'align-self', 'align-content',
          browsers: browsers

feature flexbox, match: /a\sx\s#1/, (browsers) ->
  browsers = map browsers, (i, name) ->
    if name == 'firefox' or name == 'and_ff' then i else i + ' 2009'

  prefix 'display-flex', 'inline-flex',
          props:  ['display']
          browsers: browsers
  prefix 'flex', 'flex-grow', 'flex-shrink', 'flex-basis',
          transition: true
          browsers:   browsers
  prefix 'flex-direction', 'flex-wrap', 'flex-flow', 'justify-content',
         'order', 'align-items', 'align-self', 'align-content',
          browsers: browsers

# calc() unit
feature require('caniuse-db/features-json/calc'), (browsers) ->
  prefix 'calc',
          props:  ['*']
          browsers: browsers

# Background options
feature require('caniuse-db/features-json/background-img-opts'), (browsers) ->
  prefix 'background-clip', 'background-origin', 'background-size',
          browsers: browsers

# Font feature settings
feature require('caniuse-db/features-json/font-feature'), (browsers) ->
  prefix 'font-feature-settings', 'font-variant-ligatures',
         'font-language-override','font-kerning',
          browsers: browsers

# Border image
feature require('caniuse-db/features-json/border-image'), (browsers) ->
  prefix 'border-image',
          browsers: browsers

# Selection selector
feature require('caniuse-db/features-json/css-selection'), (browsers) ->
  prefix '::selection',
          selector: true,
          browsers: browsers

# Placeholder selector
feature require('caniuse-db/features-json/css-placeholder'), (browsers) ->
  browsers = map browsers, (browser, name, version) ->
    if name == 'firefox' and version <= 18
      browser + ' old'
    else
      browser

  prefix '::placeholder',
          selector: true,
          browsers: browsers

# Hyphenation
feature require('caniuse-db/features-json/css-hyphens'), (browsers) ->
  prefix 'hyphens',
          browsers: browsers

# Fullscreen selector
feature require('caniuse-db/features-json/fullscreen'), (browsers) ->
  prefix ':fullscreen',
          selector: true,
          browsers: browsers

# Tab size
feature require('caniuse-db/features-json/css3-tabsize'), (browsers) ->
  prefix 'tab-size',
          browsers: browsers

# Intrinsic & extrinsic sizing
feature require('caniuse-db/features-json/intrinsic-width'), (browsers) ->
  prefix 'max-content', 'min-content', 'fit-content', 'fill-available',
          props:  ['width',  'min-width',  'max-width',
                   'height', 'min-height', 'max-height']
          browsers: browsers

# Zoom and grab cursor
feature require('caniuse-db/features-json/css3-cursors-newer'), (browsers) ->
  prefix 'zoom-in', 'zoom-out',
          props:  ['cursor']
          browsers: browsers.concat ['chrome 3']

  prefix 'grab', 'grabbing',
          props:  ['cursor']
          browsers: browsers.concat ['firefox 24', 'firefox 25', 'firefox 26']

# Sticky position
feature require('caniuse-db/features-json/css-sticky'), (browsers) ->
  prefix 'sticky',
          props:  ['position']
          browsers: browsers

# Pointer Events
feature require('caniuse-db/features-json/pointer'), (browsers) ->
  prefix 'touch-action',
          browsers: browsers

# Text decoration
textDecoration = require('caniuse-db/features-json/text-decoration')

feature textDecoration, (browsers) ->
  prefix 'text-decoration-style',
          browsers: browsers

feature textDecoration, match: /y\sx($|\s)/, (browsers) ->
  prefix 'text-decoration-line',
         'text-decoration-color',
          browsers: browsers

# Text Size Adjust
feature require('caniuse-db/features-json/text-size-adjust'), (browsers) ->
  prefix 'text-size-adjust',
          browsers: browsers

# CSS Masks
feature require('caniuse-db/features-json/css-masks'), (browsers) ->
  prefix 'clip-path', 'mask', 'mask-clip', 'mask-composite', 'mask-image',
         'mask-origin', 'mask-position', 'mask-repeat', 'mask-size',
          browsers: browsers

# Fragmented Borders and Backgrounds
feature require('caniuse-db/features-json/css-boxdecorationbreak'), (brwsrs) ->
  prefix 'box-decoration-break',
          browsers: brwsrs

# CSS3 object-fit/object-position
feature require('caniuse-db/features-json/object-fit'), (browsers) ->
  prefix 'object-fit',
         'object-position',
          browsers: browsers

# CSS Shapes
feature require('caniuse-db/features-json/css-shapes'), (browsers) ->
  prefix 'shape-margin',
         'shape-outside',
         'shape-image-threshold',
          browsers: browsers

# CSS3 text-overflow
feature require('caniuse-db/features-json/text-overflow'), (browsers) ->
  prefix 'text-overflow',
          browsers: browsers

# CSS3 text-emphasis
feature require('caniuse-db/features-json/text-emphasis'), (browsers) ->
  prefix 'text-emphasis',
          browsers: browsers

# Viewport at-rule
feature require('caniuse-db/features-json/css-deviceadaptation'), (browsers) ->
  prefix '@viewport',
          browsers: browsers

# Resolution Media Queries
resolution = require('caniuse-db/features-json/css-media-resolution')
feature resolution, match: /( x($| )|a #3)/, (browsers) ->
  prefix '@resolution',
          browsers: browsers

# CSS text-align-last
feature require('caniuse-db/features-json/css-text-align-last'), (browsers) ->
  prefix 'text-align-last',
          browsers: browsers

# Crisp Edges Image Rendering Algorithm
feature require('caniuse-db/features-json/css-crisp-edges'), (browsers) ->
  prefix 'crisp-edges',
          props:  ['image-rendering']
          browsers: browsers

# Logical Properties
logicalProps = require('caniuse-db/features-json/css-logical-props')

feature logicalProps, (browsers) ->
  prefix 'margin-inline-start',  'margin-inline-end',
         'padding-inline-start', 'padding-inline-end',
         'border-inline-start', 'border-inline-end',
          transition: true
          browsers:   browsers

feature logicalProps, (browsers) ->
  browsers = filter browsers, (i) -> i != 'firefox' and i != 'and_ff'
  prefix 'margin-block-start',   'margin-block-end',
         'padding-block-start',  'padding-block-end',
         'border-block-start',  'border-block-end',
          transition: true
          browsers:   browsers
