#pragma once

// I2C Pins
#define SDA_PIN 9
#define SCL_PIN 10
#define MPU_ADDR 0x68

// Airdrum Tuning (8g / 1000dps range)
#define IMPACT_GATE 2000.0    // Delta acceleration threshold to start hit
#define GYRO_GATE 3000.0      // Min gyro magnitude to allow hit
#define PEAK_MIN 4500.0       // Min peak jerk to count as hit
#define PEAK_WINDOW_MS 10
#define HIT_COOLDOWN_MS 150
