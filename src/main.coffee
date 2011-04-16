# Adapted from http://www.khronos.org/webgl/wiki/Tutorial

canvas = $("canvas").get(0)

vshader = Shader("vertex", """
  uniform mat4 u_modelViewProjMatrix;
  uniform mat4 u_normalMatrix;
  uniform vec3 lightDir;

  attribute vec3 vNormal;
  attribute vec4 vTexCoord;
  attribute vec4 vPosition;

  varying float v_Dot;
  varying vec2 v_texCoord;

  void main()
  {
      gl_Position = u_modelViewProjMatrix * vPosition;
      v_texCoord = vTexCoord.st;
      vec4 transNormal = u_normalMatrix * vec4(vNormal, 1);
      v_Dot = max(dot(transNormal.xyz, lightDir), 0.0);
  }
""")

fshader = Shader("fragment", """
  #ifdef GL_ES
    precision mediump float;
  #endif

  uniform sampler2D sampler2d;
  uniform float t;

  varying float v_Dot;
  varying vec2 v_texCoord;

  void main()
  {
      float time = t;
      float x = gl_FragCoord.x;
      float y = gl_FragCoord.y;
      float mov0 = x+y+cos(sin(time)*2.)*100.+sin(x/100.)*1000.;
      float mov1 = x / 120. / 0.2 + time;
      float mov2 = y / 75. / 0.2;
      float c1 = abs(sin(mov1+time)/2.+mov2/2.-mov1-mov2+time);
      float c2 = abs(sin(c1+sin(mov0/1000.+time)+sin(y/40.+time)+sin((x+y)/100.)*3.));
      float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.)));
      gl_FragColor = vec4(vec3(c1, c2, c3) * max(v_Dot, 0.5), 1);
  }
""")

width = -1
height = -1
currentAngle = 0
incAngle = 0.5
texture = null
framerate = null
t = 0

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
    [ "vNormal", "vColor", "vPosition"],
    # The clear color and depth values
    [ 0, 0, 0.5, 1 ], 10000
  )

  return unless gl

  # Set some uniform variables for the shaders
  setUniform(gl, "lightDir", "3f", 0, 0, 1)
  setUniform(gl, "sampler2d", "1i", 0)

  # Enable texturing
  gl.enable(gl.TEXTURE_2D)

  # Create a box. On return 'gl' contains a 'box' property with
  # the BufferObjects containing the arrays for vertices,
  # normals, texture coords, and indices.
  gl.box = makeBox(gl)

  # Load an image to use. Returns a WebGLTexture object
  texture = loadImageTexture(gl, "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAADF0lEQVRYR51Xu24UQRCcPR/ODJZBFqSWQIKARwAJJMghfCsigAgMv4AJQALJIUYWWIaMs33L1dzVqLane7xwiX2386iurq7u7c6/HfaTG9fTv37mh9/DLdF5umd+dJT3d6cf9nv8M713N3FBCxDWYPP8x08XwOTa1TTZ3k56Bs/Vff3xceq2tlL35+27DAAbeSj+ByD7me29T9zIPbjMfuzluFjXMfoBA/hy/uXrkpYFsumd24MocPn84CA/n+zsDJ4jwhbtZ58+V+dxT9cvPh5FCgDPcQijX999WoJmSiztXHC2/3EJ2qSFzzMAfiEQi5iXUCtKOcFZxrCmtc8FwE0eZYjE0wV+h3ZaAKLoc7qVAfyglFXqApVSsow+M2M0owx4wJspoGpZNjg859H4BaO3VaOp9MpSA6s0gEuJOLpAU5WBrWo//74qOaSRz0YxQDoVsVJsowQ4LVtUSM7pooT5P75fevI4LNGBBhSAIiYLmmeuhS90m5uVVPqTk9T/+p26K5fT9NFDV7yVBlrlxGjXbt0sh2n9KwKkAMwABMBhD11Q0xsC8GwYAE7f7OWI1p8/qypBxckqyvkXm4YmwJhlpIjQo5oo8Wz24mXqNjbS2oP7iU6o3Q0g1FGt8GjlLgDSSVEp1VT87NXrpaqDPmDBWGFEhlV6Ab2euVP1ajV4peVVkALQtFhmSgrUPFTxWvPastX5LvILNTRrZpUVe91NK4SHUazaKal46oF/aU5ey64AMGLP82lSdDlatLZqrGEFKNhR7bhyFFirGcF4AddGE5HtB5EduwzwcBWXzoCIXMeqKLrIXTXQJgArLvudUV40jllRjwLg9fpWc/LSh99aFTJoRvaAMc0pmp4HvWE1T0YshCnQ0suqlmFEbXsMiNbYFpYhu5p2s/8FocOpFaw7EUHxGCpgy2gerZEba1marcmHdmwH2NILWFZabgBhG5OnFfvmY1OmXdX6R3431ChsD1dn08tt6dleEmmDTJRxTt8NLYWaO2UmmnS1L2A2bIEoU5O+HUe1rL2+UBi80qt1t0ZyVsZfiOFPRiQlkMcAAAAASUVORK5CYII=")

  # Create some matrices to use later and save their locations in the shaders
  gl.mvMatrix = new J3DIMatrix4()
  gl.u_normalMatrixLoc = gl.getUniformLocation(gl.program, "u_normalMatrix")
  gl.normalMatrix = new J3DIMatrix4()
  gl.u_modelViewProjMatrixLoc =
    gl.getUniformLocation(gl.program, "u_modelViewProjMatrix")
  gl.mvpMatrix = new J3DIMatrix4()

  # Enable all of the vertex attribute arrays.
  gl.enableVertexAttribArray(0)
  gl.enableVertexAttribArray(1)
  gl.enableVertexAttribArray(2)

  # Set up all the vertex attributes for vertices, normals and texCoords
  gl.bindBuffer(gl.ARRAY_BUFFER, gl.box.vertexObject)
  gl.vertexAttribPointer(2, 3, gl.FLOAT, false, 0, 0)

  gl.bindBuffer(gl.ARRAY_BUFFER, gl.box.normalObject)
  gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 0, 0)

  gl.bindBuffer(gl.ARRAY_BUFFER, gl.box.texCoordObject)
  gl.vertexAttribPointer(1, 2, gl.FLOAT, false, 0, 0)

  # Bind the index array
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, gl.box.indexObject)

  return gl

reshape = (gl) ->
  return if (canvas.width == width && canvas.height == height)

  width = canvas.width
  height = canvas.height

  # Set the viewport and projection matrix for the scene
  gl.viewport(0, 0, width, height)
  gl.perspectiveMatrix = new J3DIMatrix4()
  gl.perspectiveMatrix.perspective(10, width/height, 1, 10000)
  gl.perspectiveMatrix.lookat(0, 0, 7, 0, 0, 0, 0, 1, 0)

drawPicture = (gl) ->
  t += 0.05

  setUniform(gl, "t", "1f", t)

  # Make sure the canvas is sized correctly.
  reshape(gl)

  # Clear the canvas
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  # Make a model/view matrix.
  gl.mvMatrix.makeIdentity()

  # Construct the normal matrix from the model-view matrix and pass it in
  gl.normalMatrix.load(gl.mvMatrix)
  gl.normalMatrix.invert()
  gl.normalMatrix.transpose()
  gl.normalMatrix.setUniform(gl, gl.u_normalMatrixLoc, false)

  # Construct the model-view * projection matrix and pass it in
  gl.mvpMatrix.load(gl.perspectiveMatrix)
  gl.mvpMatrix.multiply(gl.mvMatrix)
  gl.mvpMatrix.setUniform(gl, gl.u_modelViewProjMatrixLoc, false)

  # Bind the texture to use
  gl.bindTexture(gl.TEXTURE_2D, texture)

  # Draw the cube
  gl.drawElements(gl.TRIANGLES, gl.box.numIndices, gl.UNSIGNED_BYTE, 0)

  # Show the framerate
  framerate.snapshot()

  currentAngle += incAngle
  currentAngle -= 360 if (currentAngle > 360)

start = ->
  return unless (gl = init())

  framerate = Framerate()

  f = ->
    window.requestAnimFrame(f, canvas)
    drawPicture(gl)

  window.requestAnimFrame(f, canvas)

$ ->
  start()

