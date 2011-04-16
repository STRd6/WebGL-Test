FragmentShaderGenerator = (I) ->
  I ||= {}

  $.reverseMerge I,
    depth: 5

  leafNodes = ["x", "x", "y", "y", "t", "1.", "-1."]

  expressions = [
    "abs(#)"
    "cos(PI * #)"
    "sin(PI * #)"
    #"tan(PI * #)"
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

  preset: () ->
    [
     "float r = (sin(PI * (((y * x) / sin(PI * 1.)) * -1.0)) / (((((((y) + cos(PI * x)) / 2.0) + 1.0) / 2.0) + cos(PI * ((cos(PI * y) + ((1. + x) / 2.0)) / 2.0))) / 2.0));"
     "float g = 0.;"#"float g = sin(PI * sin(PI * (sin(PI * (y / x)) / sin(PI * (-1. / x)))));", 
     "float b = abs(((abs(cos(PI * pow(y, 3.))) + cos(PI * ((((x + x) / 2.0) + pow(y, 3.)) / 2.0))) / 2.0));"
    ].join("\n")

  generate: ->
    functions = ["r", "g", "b"].map((c) ->
      "float #{c} = #{createFunction(I.depth)};"
    )

    console.log(functions)

    functions.join("\n")

