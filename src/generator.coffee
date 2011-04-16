FragmentShaderGenerator = (I) ->
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
      "float #{c} = #{createFunction(3)};"
    ).join("\n")

