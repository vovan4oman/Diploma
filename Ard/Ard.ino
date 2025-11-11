#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

// Перейменуємо константу широти, щоб уникнути конфлікту з макросом B0
const float KYIV_LAT = 50.45 * PI / 180.0;
const float OMEGA = 7.292115e-5;

int16_t ax_raw, ay_raw, az_raw;
int16_t gx_raw, gy_raw, gz_raw;
float ax, ay, az;
float gx, gy, gz;
float g;
float wx, wy, wz;

float c11, c12, c13;
float c21, c22, c23;
float c31, c32, c33;

float pitch, roll, yaw;

float pitch_filtered = 0;
float roll_filtered = 0;
float pitch_prev = 0;
float roll_prev = 0;
float alpha_pitch_roll = 0.96;

float yaw_prev = 0;
float yaw_velocity = 0;
float yaw_integrated = 0;
float yaw_filtered = 0;
unsigned long last_time = 0;
float alpha = 0.98;
bool yaw_initialized = false;

float ax_offset = 0, ay_offset = 0, az_offset = 0;
float gx_offset = 0, gy_offset = 0, gz_offset = 0;

void setup() {
  Serial.begin(115200);
  Wire.begin();

  Serial.println("Ініціалізація MPU6050...");
  mpu.initialize();

  if (!mpu.testConnection()) {
    Serial.println("Помилка з'єднання з MPU6050!");
    while (1);
  }

  Serial.println("Знайдено MPU6050.");
  mpu.setFullScaleGyroRange(MPU6050_GYRO_FS_2000);
  mpu.setFullScaleAccelRange(MPU6050_ACCEL_FS_2);

  pitch_filtered = 0;
  roll_filtered = 0;
  pitch_prev = 0;
  roll_prev = 0;

  calibrateSensors();
  last_time = millis();

  Serial.println("Arduino готовий до роботи");
}

void loop() {
  unsigned long current_time = millis();
  float dt = (current_time - last_time) / 1000.0;
  last_time = current_time;
  if (dt > 1.0 || dt < 0) dt = 0.01;

  mpu.getMotion6(&ax_raw, &ay_raw, &az_raw, &gx_raw, &gy_raw, &gz_raw);

  ax = (float)(ax_raw - ax_offset) / 16384.0;
  ay = (float)(ay_raw - ay_offset) / 16384.0;
  az = (float)(az_raw - az_offset) / 16384.0;

  wx = (float)(gx_raw - gx_offset) * (2000.0 / 32768.0) * (PI / 180.0);
  wy = (float)(gy_raw - gy_offset) * (2000.0 / 32768.0) * (PI / 180.0);
  wz = (float)(gz_raw - gz_offset) * (2000.0 / 32768.0) * (PI / 180.0);

  calculateOrientation(dt);
  sendDataToProcessing();

  delay(20);
}

void calibrateSensors() {
  Serial.println("Калібрування датчиків...");
  Serial.println("Переконайтеся, що MPU6050 нерухомий");
  delay(2000);

  long ax_sum = 0, ay_sum = 0, az_sum = 0;
  long gx_sum = 0, gy_sum = 0, gz_sum = 0;
  int samples = 500;

  for(int i = 0; i < samples; i++) {
    mpu.getMotion6(&ax_raw, &ay_raw, &az_raw, &gx_raw, &gy_raw, &gz_raw);
    ax_sum += ax_raw;
    ay_sum += ay_raw;
    az_sum += az_raw - 16384;

    gx_sum += gx_raw;
    gy_sum += gy_raw;
    gz_sum += gz_raw;
    delay(2);
  }

  ax_offset = ax_sum / samples;
  ay_offset = ay_sum / samples;
  az_offset = az_sum / samples;

  gx_offset = gx_sum / samples;
  gy_offset = gy_sum / samples;
  gz_offset = gz_sum / samples;

  Serial.println("Калібрування завершено");
  Serial.print("Зміщення акселерометра: ");
  Serial.print(ax_offset); Serial.print(", ");
  Serial.print(ay_offset); Serial.print(", ");
  Serial.println(az_offset);

  Serial.print("Зміщення гіроскопа: ");
  Serial.print(gx_offset); Serial.print(", ");
  Serial.print(gy_offset); Serial.print(", ");
  Serial.println(gz_offset);
}

void calculateOrientation(float dt) {
  g = sqrt(ax*ax + ay*ay + az*az);
  if (g < 0.01) g = 0.01;

  c12 = -ax / g;
  c22 = -ay / g;
  c32 = -az / g;

  float roll_acc = asin(c12);
  float pitch_acc = -atan2(c32, c22);

  roll_acc = roll_acc * 180.0 / PI;
  pitch_acc = pitch_acc * 180.0 / PI;

  float pitch_gyro = pitch_prev + (wx * 180.0 / PI) * dt;
  float roll_gyro = roll_prev + (wy * 180.0 / PI) * dt;

  float alpha = alpha_pitch_roll;
  float acceleration_magnitude = sqrt(ax*ax + ay*ay + az*az);
  if (abs(acceleration_magnitude - 1.0) > 0.2) {
    alpha = 0.98;
  }

  pitch_filtered = alpha * pitch_gyro + (1 - alpha) * pitch_acc;
  roll_filtered = alpha * roll_gyro + (1 - alpha) * roll_acc;

  pitch_filtered = constrain(pitch_filtered, -180, 180);
  roll_filtered = constrain(roll_filtered, -180, 180);

  pitch_prev = pitch_filtered;
  roll_prev = roll_filtered;

  pitch = pitch_filtered;
  roll = roll_filtered;

  if (!yaw_initialized) {
    yaw_integrated = 0;
    yaw_prev = 0;
    yaw_initialized = true;
  }

  yaw_integrated += wz * dt;
  yaw_filtered = alpha * (yaw_prev + wz * dt) + (1 - alpha) * yaw_integrated;
  yaw_prev = yaw_filtered;
  yaw = yaw_filtered * 180.0 / PI;

  if (yaw > 180) yaw -= 360;
  if (yaw < -180) yaw += 360;
}

void sendDataToProcessing() {
  Serial.print("ANGLES:");
  Serial.print(pitch);
  Serial.print(":");
  Serial.print(roll);
  Serial.print(":");
  Serial.println(yaw);
}
