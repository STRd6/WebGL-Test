FragmentShaderGenerator = (I) ->
  I ||= {}

  $.reverseMerge I,
    depth: 4

  leafNodes = ["x", "x", "y", "y", "t"]

  expressions = [
    "cos(PI * #)"
    "sin(PI * #)"
    "(# * #)"
    "(# / #)"
    "((# + #) / 2.0)"
  ]

  createFunction = (depth) ->
    if depth == 0
      leafNodes.rand()
    else
      expressions.rand().replace(/#/g, -> createFunction(depth-1))

  generate: ->
    functions = ["r", "g", "b"].map((c) ->
      "float #{c} = #{createFunction(I.depth)};"
    )

    console.log(functions)

    functions.join("\n")

