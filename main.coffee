bind = rx.bind
rx.rxt.importTags()

class Gist
  constructor: (@id, @desc, @content) ->

gistsAll = rx.array([
  new Gist(1, 'javascript', 'var x = 1;'),
  new Gist(2, 'java', 'int x = 1;'),
  new Gist(3, 'python', 'x = 3')
])

currentGist = rx.cell(gistsAll.at(0))
$('body').append(
  div {class: 'container'}, [
    div {class: 'sidebar'}, [
      ul {}, gistsAll.map (g) ->
        li {class: "#{if g == currentGist.get() then 'selected'}", click: -> currentGist.set(g)}, g.desc
    ]
    div {class: 'preview'}, [
      h3 {}, bind -> currentGist.get().desc
      pre {}, bind -> currentGist.get().content
    ]
  ]
)