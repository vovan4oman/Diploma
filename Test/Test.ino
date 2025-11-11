#include "MPU9250.h"

MPU9250 mpu;

void setup() {
    Serial.begin(115200);
    Wire.begin();
    delay(2000);

    if (!mpu.setup(0x68)) {  // адреса може бути іншою, залежно від вашого пристрою
        while (1) {
            Serial.println("MPU connection failed. Please check your connection with `connection_check` example.");
            delay(5000);
        }
    }
}

void loop() {
    if (mpu.update()) {
        static uint32_t prev_ms = millis();
        if (millis() > prev_ms + 25) {
            send_roll_pitch_yaw();
            prev_ms = millis();
        }
    }
}

void send_roll_pitch_yaw() {
    // Формат відправки даних: "YAW:X,PITCH:Y,ROLL:Z"
    // Такий формат легше розпарсити в Processing
    Serial.print("YAW:");
    Serial.print(mpu.getYaw(), 2);
    Serial.print(",PITCH:");
    Serial.print(mpu.getPitch(), 2);
    Serial.print(",ROLL:");
    Serial.print(mpu.getRoll(), 2);
    Serial.println(); // Завершуємо рядок
}