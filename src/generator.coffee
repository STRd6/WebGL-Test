FragmentShaderGenerator = (I) ->
  I ||= {}

  $.reverseMerge I,
    depth: 3

  leafNodes = ["x", "y", "t"]

  expressions = [
    "cos(PI * #)"
    "sin(PI * #)"
    "(# * #)"
    "(# / #)"
    "((# + #) / 2)"
  ]

  createFunction = (depth) ->
    if depth == 0
      leafNodes.rand()
    else
      expressions.rand().replace("#", -> createFunction(depth-1))

  generate: ->
    ["r", "g", "b"].map((c) ->
      "float #{c} = #{createFunction(I.depth)};"
    ).join("\n")

