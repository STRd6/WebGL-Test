FragmentShaderGenerator = (I) ->
  I ||= {}

  $.reverseMerge I,
    depth: 5

  leafNodes = ["x", "x", "y", "y", "t", "1.", "-1."]

  expressions = [
    "cos(PI * #)"
    "sin(PI * #)"
    "(# * #)"
    "(# / #)"
    "((# + #) / 2.0)"
    "pow(#, 3.)"
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

