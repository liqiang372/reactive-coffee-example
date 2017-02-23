bind = rx.bind
rx.rxt.importTags()


###
# Basic Data Type
###
class Gist
  constructor: (@id, @desc, @files) ->

###
# Component
###
sidebar = (args) ->
  gists = args.gists
  currentGist = args.currentGist

  div {class: 'sidebar'}, [
    ul {}, gists.map (g) ->
      li {
        class: "#{if g == currentGist.get() then 'selected' else ''}"
        click: -> currentGist.set(g) 
      }, do ->
        keys = Object.keys(g.files)
        [
          p {}, [
            span {class: 'list-filename'}, g.files[keys[0]].filename
            br()
            span {class: 'list-filedesc'}, g.desc
          ]
        ]
  ]

###
# Component
###
preview = (args) ->
  gists = args.gists
  currentGist = args.currentGist

  div {class: 'preview'}, [
    h3 {}, bind -> currentGist.get().desc

    div {}, bind ->
      for fileName, file of currentGist.get().files
        do (fileName, file) ->
          fileContent = rx.cell('')
          # highlight code at the end of updating
          fileContent.onSet.sub () ->
            setTimeout ->
              $('pre code').each (i, block) -> hljs.highlightBlock(block)
            , 0
          $.ajax({
            url: file.raw_url,
            success: (data) -> fileContent.set(data)
          })
          div {}, [
            i {click: -> $code.slideToggle('fast')}, fileName
            pre {}, [
              $code = code {class: "#{if file.language? then file.language.toLowerCase()}"}, bind -> fileContent.get()
            ]
          ]
  ]


###
# Root Entry
###
main = (args) ->
  gistsAll = rx.array([])
  ## need to provide a placeholder value here to avoid multiple dependency updates
  currentGist = rx.cell("loading...", "loading", {"filename": {"language": "javascript"}})

  fetching = rx.cell(false)
  err = rx.cell(false)
  displayName = rx.cell('')

  loadFromGithub = (name) ->
    fetching.set(true)
    err.set(false)
    displayName.set(name)
    $.ajax({
      url: "https://api.github.com/users/#{name}/gists",
      success: (data) -> 
        gistsAll.replace(data.map (g) -> new Gist(g.id, g.description, g.files))
        currentGist.set(gistsAll.at(0))
      error: () -> err.set(true)
      finally: () -> fetching.set(false)
    })
  
  loadFromGithub('drbelfast')
  
  $base = div {class: 'hi'}, [
    h1 'hello'
    div {}, [
      input {
        type: 'text'
        placeholder: 'type username'
        autofocus: true
        keydown: (e) ->
          if (e.which == 13)
            name = @val().trim()
            if (name.length == 0) then return
            loadFromGithub(name)
      }
    ]
    p {}, bind -> "#{displayName.get()}'s gists"
    div {class: 'container'}, bind ->
      if err.get()
        [div 'no user exists']
      else
        if gistsAll.length() > 0
          [
            sidebar {gists: gistsAll, currentGist: currentGist}
            preview {gists: gistsAll, currentGist: currentGist}
          ]
        else
          if fetching.get()
            [div {}, 'fetching...']
          else
            [div {}, '']
  ]
  $base

## Start Everything
$('body').append(main)