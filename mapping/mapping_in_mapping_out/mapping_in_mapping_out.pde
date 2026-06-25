import processing.video.*;
import java.io.File;

// Mapping de entrada y salida:
// i = editar input
// o = editar output
// 1..4 = elegir vertice
// flechas = mover vertice
// s = guardar

final String CONFIG_FILE = "mapping_in_mapping_out.json";
final int MODO_PRESENTAR = 0;
final int MODO_EDITAR_INPUT = 1;
final int MODO_EDITAR_OUTPUT = 2;

Capture cam;
PVector[] esquinasInput = new PVector[4];
PVector[] esquinasOutput = new PVector[4];

int mode = MODO_PRESENTAR;
boolean dragging = false;
int esquinaSeleccionada = 0;
float handleRadius = 18;
float nudge = 0.0025;

void settings() {
  fullScreen(P2D);
}

void setup() {
  textureMode(IMAGE);
  setupCamera();
  loadCorners();
}

void draw() {
  if (cam != null && cam.available()) {
    cam.read();
  }

  background(0);

  if (cam == null) {
    drawCameraError();
    return;
  }

  if (mode == MODO_EDITAR_INPUT) {
    image(cam, 0, 0, width, height);
    dibujarPoligonoIndicador(esquinasInput, color(255, 170, 0));
    drawEditorInfo("EDITANDO INPUT");
    return;
  }

  drawMappedInputOutput();

  if (mode == MODO_EDITAR_OUTPUT) {
    dibujarPoligonoIndicador(esquinasOutput, color(0, 220, 255));
    drawEditorInfo("EDITANDO OUTPUT");
  }
}

void setupCamera() {
  String[] cameras = Capture.list();

  if (cameras == null || cameras.length == 0) {
    cam = null;
    return;
  }

  cam = new Capture(this, cameras[0]);
  cam.start();
}

void drawCameraError() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("No se encontro una webcam.", width * 0.5, height * 0.5);
}

void drawMappedInputOutput() {
  noStroke();
  beginShape();
  texture(cam);
  vertex(esquinasOutput[0].x * width, esquinasOutput[0].y * height, esquinasInput[0].x * cam.width, esquinasInput[0].y * cam.height);
  vertex(esquinasOutput[1].x * width, esquinasOutput[1].y * height, esquinasInput[1].x * cam.width, esquinasInput[1].y * cam.height);
  vertex(esquinasOutput[2].x * width, esquinasOutput[2].y * height, esquinasInput[2].x * cam.width, esquinasInput[2].y * cam.height);
  vertex(esquinasOutput[3].x * width, esquinasOutput[3].y * height, esquinasInput[3].x * cam.width, esquinasInput[3].y * cam.height);
  endShape(CLOSE);
}

void dibujarPoligonoIndicador(PVector[] corners, int accent) {
  stroke(accent);
  strokeWeight(2);
  noFill();
  beginShape();

  for (int i = 0; i < corners.length; i++) {
    float px = corners[i].x * width;
    float py = corners[i].y * height;
    vertex(px, py);
  }

  endShape(CLOSE);

  for (int i = 0; i < corners.length; i++) {
    float px = corners[i].x * width;
    float py = corners[i].y * height;
    boolean active = i == esquinaSeleccionada;
    dibujarHandle(px, py, active, accent);
  }
}

void dibujarHandle(float x, float y, boolean active, int accent) {
  stroke(active ? color(255) : accent);
  strokeWeight(active ? 3 : 2);
  fill(0, 140);
  ellipse(x, y, handleRadius * 2, handleRadius * 2);
  line(x - 8, y, x + 8, y);
  line(x, y - 8, x, y + 8);
}

void drawEditorInfo(String title) {
  fill(0, 180);
  noStroke();
  rect(20, 20, 470, 80, 10);
  fill(255);
  textAlign(LEFT, TOP);
  textSize(20);
  text(title, 40, 36);
  textSize(14);
  text("i/o: cambiar modo  |  1..4: vertice  |  mouse/flechas: mover  |  s: guardar", 40, 66);
}

void loadCorners() {
  String path = sketchPath(CONFIG_FILE);
  File file = new File(path);

  if (!file.exists()) {
    setDefaultCorners();
    return;
  }

  JSONObject json = loadJSONObject(path);
  loadArray(json.getJSONArray("input"), esquinasInput);
  loadArray(json.getJSONArray("output"), esquinasOutput);
}

void loadArray(JSONArray points, PVector[] corners) {
  for (int i = 0; i < 4; i++) {
    JSONObject point = points.getJSONObject(i);
    corners[i] = new PVector(point.getFloat("x"), point.getFloat("y"));
  }
}

void setDefaultCorners() {
  esquinasInput[0] = new PVector(0.15, 0.15);
  esquinasInput[1] = new PVector(0.85, 0.15);
  esquinasInput[2] = new PVector(0.85, 0.85);
  esquinasInput[3] = new PVector(0.15, 0.85);

  esquinasOutput[0] = new PVector(0.08, 0.08);
  esquinasOutput[1] = new PVector(0.92, 0.08);
  esquinasOutput[2] = new PVector(0.92, 0.92);
  esquinasOutput[3] = new PVector(0.08, 0.92);
}

void saveCorners() {
  JSONObject json = new JSONObject();
  json.setJSONArray("input", saveArray(esquinasInput));
  json.setJSONArray("output", saveArray(esquinasOutput));
  saveJSONObject(json, sketchPath(CONFIG_FILE));
}

JSONArray saveArray(PVector[] corners) {
  JSONArray points = new JSONArray();

  for (int i = 0; i < 4; i++) {
    JSONObject point = new JSONObject();
    point.setFloat("x", corners[i].x);
    point.setFloat("y", corners[i].y);
    points.setJSONObject(i, point);
  }

  return points;
}

void keyPressed() {
  if (key == 'i' || key == 'I') {
    mode = mode == MODO_EDITAR_INPUT ? MODO_PRESENTAR : MODO_EDITAR_INPUT;
  }

  if (key == 'o' || key == 'O') {
    mode = mode == MODO_EDITAR_OUTPUT ? MODO_PRESENTAR : MODO_EDITAR_OUTPUT;
  }

  if (key == 's' || key == 'S') {
    saveCorners();
  }

  if (key >= '1' && key <= '4') {
    esquinaSeleccionada = key - '1';
  }

  if (keyCode == LEFT) moveesquinaSeleccionada(-nudge, 0);
  if (keyCode == RIGHT) moveesquinaSeleccionada(nudge, 0);
  if (keyCode == UP) moveesquinaSeleccionada(0, -nudge);
  if (keyCode == DOWN) moveesquinaSeleccionada(0, nudge);
}

void moveesquinaSeleccionada(float dx, float dy) {
  PVector[] corners = getActiveCorners();

  if (corners == null) return;

  corners[esquinaSeleccionada].x = constrain(corners[esquinaSeleccionada].x + dx, 0, 1);
  corners[esquinaSeleccionada].y = constrain(corners[esquinaSeleccionada].y + dy, 0, 1);
}

PVector[] getActiveCorners() {
  if (mode == MODO_EDITAR_INPUT) return esquinasInput;
  if (mode == MODO_EDITAR_OUTPUT) return esquinasOutput;
  return null;
}

void mousePressed() {
  PVector[] corners = getActiveCorners();

  if (corners == null) return;

  int corner = findCornerAt(mouseX, mouseY, corners);

  if (corner != -1) {
    esquinaSeleccionada = corner;
    dragging = true;
    updateesquinaSeleccionadaFromMouse(corners);
  }
}

void mouseDragged() {
  PVector[] corners = getActiveCorners();

  if (corners == null || !dragging) return;
  updateesquinaSeleccionadaFromMouse(corners);
}

void mouseReleased() {
  dragging = false;
}

int findCornerAt(float mx, float my, PVector[] corners) {
  for (int i = 0; i < corners.length; i++) {
    float px = corners[i].x * width;
    float py = corners[i].y * height;

    if (dist(mx, my, px, py) <= handleRadius) {
      return i;
    }
  }

  return -1;
}

void updateesquinaSeleccionadaFromMouse(PVector[] corners) {
  corners[esquinaSeleccionada].x = constrain(mouseX / float(width), 0, 1);
  corners[esquinaSeleccionada].y = constrain(mouseY / float(height), 0, 1);
}
