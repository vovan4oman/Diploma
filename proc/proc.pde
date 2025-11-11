    import processing.serial.*;

Serial myPort;
float pitch = 0;
float roll = 0;
float yaw = 0;

// Кольори для граней кубика
color[] faceColors = {
  color(255, 0, 0),    // Червоний (передня)
  color(0, 255, 0),    // Зелений (задня)
  color(0, 0, 255),    // Синій (верхня)
  color(255, 255, 0),  // Жовтий (нижня)
  color(255, 0, 255),  // Пурпурний (ліва)
  color(0, 255, 255)   // Бірюзовий (права)
};

void setup() {
  size(800, 600, P3D);
  
  // Використовуємо конкретно COM5
  String portName = "COM5";
  try {
    myPort = new Serial(this, portName, 115200);
    myPort.bufferUntil('\n');
    println("Підключено до порту " + portName);
  } catch (Exception e) {
    println("Помилка підключення до порту " + portName);
    println("Доступні порти:");
    printArray(Serial.list());
    exit();
  }
}

void draw() {
  background(32);
  
  // Інформаційний текст
  fill(255);
  textSize(16);
  text("Кути повороту від MPU6050:", 20, 30);
  text("Тангаж (Pitch): " + nf(pitch, 0, 2) + "°", 20, 60);
  text("Крен (Roll): " + nf(yaw, 0, 2) + "°", 20, 90);
  text("Курс (Yaw): " + nf(roll, 0, 2) + "°", 20, 120);
  
  // Налаштування 3D-сцени
  pushMatrix();
  translate(width/2, height/2, 0);
  
  // Додаємо освітлення для кращого 3D-ефекту
  lights();
  
  // Обертання кубика
  rotateX(radians(pitch));
  rotateZ(radians(roll));
  rotateY(radians(yaw));
  
  // Малюємо кольоровий кубик
  drawColorCube(150);
  
  // Малюємо осі координат для орієнтації
  drawAxes(200);
  
  popMatrix();
}

void drawColorCube(float size) {
  stroke(0);
  strokeWeight(1);
  
  float hs = size/2;
  
  // Передня грань (червона)
  fill(faceColors[0]);
  beginShape();
  vertex(-hs, -hs, hs);
  vertex(hs, -hs, hs);
  vertex(hs, hs, hs);
  vertex(-hs, hs, hs);
  endShape(CLOSE);
  
  // Задня грань (зелена)
  fill(faceColors[1]);
  beginShape();
  vertex(-hs, -hs, -hs);
  vertex(hs, -hs, -hs);
  vertex(hs, hs, -hs);
  vertex(-hs, hs, -hs);
  endShape(CLOSE);
  
  // Верхня грань (синя)
  fill(faceColors[2]);
  beginShape();
  vertex(-hs, -hs, -hs);
  vertex(hs, -hs, -hs);
  vertex(hs, -hs, hs);
  vertex(-hs, -hs, hs);
  endShape(CLOSE);
  
  // Нижня грань (жовта)
  fill(faceColors[3]);
  beginShape();
  vertex(-hs, hs, -hs);
  vertex(hs, hs, -hs);
  vertex(hs, hs, hs);
  vertex(-hs, hs, hs);
  endShape(CLOSE);
  
  // Ліва грань (пурпурна)
  fill(faceColors[4]);
  beginShape();
  vertex(-hs, -hs, -hs);
  vertex(-hs, hs, -hs);
  vertex(-hs, hs, hs);
  vertex(-hs, -hs, hs);
  endShape(CLOSE);
  
  // Права грань (бірюзова)
  fill(faceColors[5]);
  beginShape();
  vertex(hs, -hs, -hs);
  vertex(hs, hs, -hs);
  vertex(hs, hs, hs);
  vertex(hs, -hs, hs);
  endShape(CLOSE);
  
  // Додаємо позначки осей на гранях
  fill(0);
  textSize(18);
  
  // Позначка на передній грані (вісь Z)
  pushMatrix();
  translate(0, 0, hs + 1);
  text("Z+", 0, 0);
  popMatrix();
  
  // Позначка на правій грані (вісь X)
  pushMatrix();
  translate(hs + 1, 0, 0);
  rotateY(HALF_PI);
  text("X+", 0, 0);
  popMatrix();
  
  // Позначка на верхній грані (вісь Y)
  pushMatrix();
  translate(0, -hs - 1, 0);
  rotateX(HALF_PI);
  text("Y+", 0, 0);
  popMatrix();
}

void drawAxes(float length) {
  strokeWeight(3);
  
  // Вісь X - червона
  stroke(255, 0, 0);
  line(0, 0, 0, length, 0, 0);
  
  // Вісь Y - зелена
  stroke(0, 255, 0);
  line(0, 0, 0, 0, -length, 0);
  
  // Вісь Z - синя
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, length);
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    inString = trim(inString);
    if (inString.startsWith("ANGLES:")) {
      String[] data = split(inString.substring(7), ':');
      if (data.length == 3) {
        try {
          pitch = float(data[0])-90;
          roll = float(data[1]);
          yaw = float(data[2]);
        } catch (Exception e) {
          println("Помилка обробки даних: " + inString);
        }
      }
    }
  }
}
