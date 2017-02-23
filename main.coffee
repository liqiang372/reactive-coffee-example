bind = rx.bind
rx.rxt.importTags()

class Gist
  constructor: (@id, @desc, @files) ->

sidebar = (args) ->
  gists = args.gists
  currentGist = args.currentGist

  div {class: 'sidebar'}, [
    ul {}, gists.map (g) ->
      li {class: "#{if g == currentGist.get() then 'selected' else ''}", click: -> currentGist.set(g) }, g.desc
  ]

preview = (args) ->
  gists = args.gists
  currentGist = args.currentGist

  div {class: 'preview'}, [
    h3 {}, bind -> currentGist.get().desc

    div {}, bind ->
      for fileName, file of currentGist.get().files
        do (fileName, file) ->
          fileContent = rx.cell('')
          $.ajax({
            url: file.raw_url,
            success: (data) -> fileContent.set(data)
          })
          div {}, [
            pre {}, fileName
            code {}, bind -> fileContent.get()
          ]
  ]

main = (args) ->
  gistsAll = rx.array([])
  loadFromGithub = ->
    $.ajax({
      url: 'https://api.github.com/users/drbelfast/gists',
      success: (data) -> gistsAll.replace(data.map (g) -> new Gist(g.id, g.description, g.files)) 
    })
  
  loadFromGithub()
  
  $base = div {class: 'hi'}, [
    h1 'hello'
    div {class: 'container'}, bind ->
      if gistsAll.length() > 0
        currentGist = rx.cell(gistsAll.at(0))
        [
          sidebar {gists: gistsAll, currentGist: currentGist}
          preview {gists: gistsAll, currentGist: currentGist}
        ]
      else
        [div {}, 'Loading...']
  ]
  $base

$('body').append(main)