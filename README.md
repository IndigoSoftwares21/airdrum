# AirDrum System

The **AirDrum System** is a wireless air-drumming solution consisting of hardware drum sticks (ESP32 + MPU6050) and a Flutter-based client application. It uses low-latency UDP communication to trigger drum sounds based on physical swings and impacts detected by the IMU.

---

## Hardware Wiring Guide

Use this guide to connect your components to the ESP32 board. These pins are optimized for modern ESP32 variants (like ESP32-C3 or ESP32-S3).

### Connection Table

| Component | ESP32 Pin | Description |
| :--- | :--- | :--- |
| **MPU6050 SDA** | **GPIO 9** | I2C Data Line |
| **MPU6050 SCL** | **GPIO 10** | I2C Clock Line |
| **MPU6050 VCC** | **3.3V** | Power (ensure stable 3.3V) |
| **MPU6050 GND** | **GND** | Ground |
| **RGB LED (Red)** | **GPIO 5** | State: Booting / WiFi Error |
| **RGB LED (Green)** | **GPIO 6** | State: Standby / Connected |
| **RGB LED (Blue)** | **GPIO 7** | State: Hit Detected |
| **Vibration Motor** | **GPIO 3** | Haptic Feedback on Hit |

> [!IMPORTANT]
> **Resistors:** Use ~220Ω resistors for the RGB LED pins to prevent damage.  
> **Vibration Motor:** Do NOT connect a vibration motor directly to the GPIO pin. Use a small NPN transistor (like S8050) or a MOSFET driver circuit to handle the current.

---

## Wireless Setup (No-Flash Mode)

Once you flash the firmware **once**, you never need to plug in via USB again.

### 1. App-Based Configuration ("Magic Setup" via Bluetooth)

1. Power on the stick.
2. Open the **AirDrum app** on your Mac and click **Magic Setup** in the sidebar.
3. Enter your **home WiFi name**, **password**, and **your computer's IP**.
4. Click **Scan** and tap on your stick (`AirDrum-RIGHT` or `AirDrum-LEFT`).
5. The application will seamlessly send the credentials over Bluetooth. The stick will reboot and join your network.

### 2. Wireless Code Updates (OTA)

Once the stick is on your network, you can push new firmware wirelessly:
1. In Arduino IDE go to `Tools > Port`.
2. Select `AirDrum-RIGHT` or `AirDrum-LEFT` under **Network Ports**.
3. Click **Upload** — no cable needed!

---

## Initial Firmware Setup (Arduino)

> [!IMPORTANT]
> **Partition Scheme:** Because the Bluetooth stack is large, you MUST change the partition scheme in Arduino IDE before flashing:
> Go to **Tools > Partition Scheme** and select **Minimal SPIFFS (1.9MB APP with OTA / 190KB SPIFFS)** or **Huge APP (3MB No OTA)**.

1. **Board Support:** Install the ESP32 board package in Arduino IDE (`File > Preferences > Board Manager URL`).
2. **Configuration:** Open `firmware/air_drum/config.h` and update the following:
   - `WIFI_SSID`: Your WiFi Name.
   - `WIFI_PASS`: Your WiFi Password.
   - `HOST_IP`: The IP address of the machine running the Flutter app.
   - `STICK_ID`: Set to `[LEFT]` for the left stick and `[RIGHT]` for the right stick.
3. **Flashing:** Select your board type and port, then upload `air_drum.ino`.


### Stick Status Indicators
- **Blinking Red:** Booting or searching for WiFi.
- **Blinking Yellow:** Connected to WiFi, waiting for UDP handshake/ready.
- **Blue Flash:** Impact detected (Hit!).

---

## Client Setup (Flutter)

1. Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed.
2. Navigate to the `client` directory:
   ```bash
   cd client
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Connecting to Sticks
- Ensure your phone/computer and the ESP32 sticks are on the **same WiFi network**.
- Check the `HOST_IP` in the firmware matches your device's local IP.
- The app listens on **UDP Port 8000**.

---

## Performance Tuning

If the hits are too sensitive or too dull, adjust these values in `config.h`:
- `SWING_GYRO_GATE`: Minimum rotation speed to count as a "swing".
- `IMPACT_ACCEL_GATE`: Minimum deceleration force to count as a "hit".
- `LPF_ALPHA`: Smoothing factor for the sensors.

---

## Demo & Troubleshooting
- **Demo Video:** [Watch on YouTube](https://youtu.be/GfVfOp_5rQE?si=umcly9e_Fj3HWkN6)
- **Serial Monitor:** If things aren't working, open the Serial Monitor (115200 baud) to see debug logs.
