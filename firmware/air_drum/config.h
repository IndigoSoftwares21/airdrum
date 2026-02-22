#pragma once

// I2C
#define SDA_PIN 9
#define SCL_PIN 10
#define MPU_ADDR 0x68

// Drum detection tuning
#define IMPACT_GATE 5500.0
#define PEAK_MIN 9000.0
#define PEAK_WINDOW_US 7000
#define HIT_COOLDOWN_MS 150
