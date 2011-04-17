# Adapted from http://www.khronos.org/webgl/wiki/Tutorial

canvas = $("canvas").get(0)

# pCan = $("canvas").powerCanvas()

vshader = Shader("vertex", """
  attribute vec3 position;

  void main() {
    gl_Position = vec4( position, 1.0 );
  }
""")

fshader = Shader("fragment", """
  #ifdef GL_ES
    precision mediump float;
  #endif

  uniform float t;

  void main()
  {
      float PI = 3.14159;
      float time = t;
      float x = gl_FragCoord.x / 640.;
      float y = gl_FragCoord.y / 480.;

      #{FragmentShaderGenerator().generate()}

      gl_FragColor = vec4(vec3(r, g, b), 1);
  }
""")

width = -1
height = -1
incAngle = 0.5
texture = null

framerate = null
t = 0

buffer = null
vertex_position = null

setUniform = (gl, name, type, args...) ->
  if loc = gl.getUniformLocation(gl.program, name)
    gl["uniform#{type}"].apply(gl, [loc].concat(args))

init = ->
  window.gl = initWebGL(
    # The canvas element
    canvas,
    # The vertex and fragment shader data objects
    vshader, fshader,
    # The vertex attribute names used by the shaders.
    # The order they appear here corresponds to their index
    # used later.
    [ ],
    # The clear color and depth values
    [ 0, 0, 0.5, 1 ], 10000
  )

  return unless gl

  # Create Vertex buffer (2 triangles)
  buffer = gl.createBuffer()
  gl.bindBuffer( gl.ARRAY_BUFFER, buffer )
  gl.bufferData( gl.ARRAY_BUFFER, new Float32Array( [ - 1.0, - 1.0, 1.0, - 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0 ] ), gl.STATIC_DRAW )

  # Setting position attribute???
  gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0)
  gl.enableVertexAttribArray(0)

  return gl

reshape = (gl) ->
  return if (canvas.width == width && canvas.height == height)

  width = canvas.width
  height = canvas.height

  # Set the viewport and projection matrix for the scene
  gl.viewport(0, 0, width, height)

drawPicture = (gl) ->
  t += 0.01

  setUniform(gl, "t", "1f", t)

  # Make sure the canvas is sized correctly.
  reshape(gl)

  # Clear the canvas
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  # Draw
  gl.drawArrays( gl.TRIANGLES, 0, 6 )

  # Show the framerate
  framerate.snapshot()

start = ->
  return unless (gl = init())

  framerate = Framerate()

  f = ->
    window.requestAnimFrame(f, canvas)
    drawPicture(gl)

  window.requestAnimFrame(f, canvas)

$ ->
  start()

