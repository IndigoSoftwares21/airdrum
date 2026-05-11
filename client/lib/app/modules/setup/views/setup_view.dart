import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setup_controller.dart';

class SetupView extends GetView<SetupController> {
  const SetupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned(
            top: -120, right: -80,
            child: _Glow(color: Colors.blue.withOpacity(0.15), size: 360),
          ),
          Positioned(
            bottom: -80, left: -60,
            child: _Glow(color: Colors.indigo.withOpacity(0.1), size: 300),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bluetooth_searching_rounded, color: Colors.blueAccent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text("Magic Setup",
                          style: TextStyle(color: Colors.white, fontSize: 28,
                              fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      Text("Configure sticks seamlessly via Bluetooth",
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ]),
                  ]),
                  const SizedBox(height: 20),

                  // Step 1 — Enter Credentials
                  _StepLabel(number: "1", label: "Enter Network Details"),
                  const SizedBox(height: 10),
                  _GlassCard(child: Column(children: [
                    _Field(controller: controller.ssidController, hint: "WiFi Name (SSID)", icon: Icons.wifi_rounded),
                    _Field(controller: controller.passController, hint: "WiFi Password", icon: Icons.lock_rounded, isPassword: true),
                    _Field(controller: controller.ipController, hint: "Your Computer's IP  (e.g. 192.168.1.5)", icon: Icons.computer_rounded),
                  ])),
                  const SizedBox(height: 24),

                  // Step 2 — Scan and Connect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StepLabel(number: "2", label: "Select a Stick"),
                      Obx(() => controller.isScanning.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                        : TextButton.icon(
                            onPressed: controller.startScan,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text("Scan"),
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  Obx(() => controller.foundDevices.isEmpty 
                    ? _GlassCard(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            controller.isScanning.value ? "Scanning for sticks..." : "No sticks found. Click Scan.",
                            style: const TextStyle(color: Colors.white54),
                          )
                        ),
                      ))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.foundDevices.length,
                        itemBuilder: (context, index) {
                          final result = controller.foundDevices[index];
                          return _buildStickItem(
                            result,
                            () => controller.configureStick(result.device),
                          );
                        },
                      )
                  ),
                  
                  const SizedBox(height: 24),

                  // Status
                  Obx(() => _StatusBanner(
                    status: controller.setupStatus.value,
                    done: controller.setupDone.value,
                    isConnecting: controller.isConnecting.value,
                  )),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickItem(dynamic result, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.speaker, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.device.platformName.isEmpty ? "AirDrum Stick" : result.device.platformName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Tap to configure",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox.expand()),
      );
}

class _StepLabel extends StatelessWidget {
  final String number, label;
  const _StepLabel({required this.number, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 26, height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ]);
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: child,
          ),
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  const _Field({required this.controller, required this.hint, required this.icon,
      this.isPassword = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.07))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade400)),
          ),
        ),
      );
}

class _StatusBanner extends StatelessWidget {
  final String status;
  final bool done;
  final bool isConnecting;
  const _StatusBanner({required this.status, required this.done, required this.isConnecting});
  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) return const SizedBox.shrink();
    final color = done ? Colors.green.shade400 : Colors.blue.shade300;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (isConnecting)
             const Padding(
               padding: EdgeInsets.only(right: 12),
               child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
             ),
          Expanded(child: Text(status, style: TextStyle(color: color, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}
