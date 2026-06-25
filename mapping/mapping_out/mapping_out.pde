import processing.video.*;
import java.io.File;

// Mapping de salida:
// o = editar output
// 1..4 = elegir vertice
// flechas = mover vertice
// s = guardar

final String CONFIG_FILE = "mapping_out.json";

Capture cam;
PVector[] esquinasOutput = new PVector[4];

boolean editOutput = false;
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
  cargarEsquinasOutput();
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

  drawMappedOutput();

  if (editOutput) {
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

void drawMappedOutput() {
  noStroke();
  beginShape();
  texture(cam);
  vertex(esquinasOutput[0].x * width, esquinasOutput[0].y * height, 0, 0);
  vertex(esquinasOutput[1].x * width, esquinasOutput[1].y * height, cam.width, 0);
  vertex(esquinasOutput[2].x * width, esquinasOutput[2].y * height, cam.width, cam.height);
  vertex(esquinasOutput[3].x * width, esquinasOutput[3].y * height, 0, cam.height);
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
  rect(20, 20, 430, 80, 10);
  fill(255);
  textAlign(LEFT, TOP);
  textSize(20);
  text(title, 40, 36);
  textSize(14);
  text("o: presentar  |  1..4: vertice  |  mouse/flechas: mover  |  s: guardar", 40, 66);
}

void cargarEsquinasOutput() {
  String path = sketchPath(CONFIG_FILE);
  File file = new File(path);

  if (!file.exists()) {
    setDefaultesquinasOutput();
    return;
  }

  JSONObject json = loadJSONObject(path);
  JSONArray points = json.getJSONArray("output");

  for (int i = 0; i < 4; i++) {
    JSONObject point = points.getJSONObject(i);
    esquinasOutput[i] = new PVector(point.getFloat("x"), point.getFloat("y"));
  }
}

void setDefaultesquinasOutput() {
  esquinasOutput[0] = new PVector(0.08, 0.08);
  esquinasOutput[1] = new PVector(0.92, 0.08);
  esquinasOutput[2] = new PVector(0.92, 0.92);
  esquinasOutput[3] = new PVector(0.08, 0.92);
}

void saveesquinasOutput() {
  JSONObject json = new JSONObject();
  JSONArray points = new JSONArray();

  for (int i = 0; i < 4; i++) {
    JSONObject point = new JSONObject();
    point.setFloat("x", esquinasOutput[i].x);
    point.setFloat("y", esquinasOutput[i].y);
    points.setJSONObject(i, point);
  }

  json.setJSONArray("output", points);
  saveJSONObject(json, sketchPath(CONFIG_FILE));
}

void keyPressed() {
  if (key == 'o' || key == 'O') {
    editOutput = !editOutput;
  }

  if (key == 's' || key == 'S') {
    saveesquinasOutput();
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
  esquinasOutput[esquinaSeleccionada].x = constrain(esquinasOutput[esquinaSeleccionada].x + dx, 0, 1);
  esquinasOutput[esquinaSeleccionada].y = constrain(esquinasOutput[esquinaSeleccionada].y + dy, 0, 1);
}

void mousePressed() {
  if (!editOutput) return;

  int corner = findCornerAt(mouseX, mouseY, esquinasOutput);

  if (corner != -1) {
    esquinaSeleccionada = corner;
    dragging = true;
    updateesquinaSeleccionadaFromMouse(esquinasOutput);
  }
}

void mouseDragged() {
  if (!editOutput || !dragging) return;
  updateesquinaSeleccionadaFromMouse(esquinasOutput);
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
