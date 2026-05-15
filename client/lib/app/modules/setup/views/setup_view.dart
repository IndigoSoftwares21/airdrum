import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setup_controller.dart';
import '../../../widgets/ad_text.dart';
import '../../../widgets/ad_button.dart';

class SetupView extends GetView<SetupController> {
  const SetupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────
          Container(
            width: 240,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                const SizedBox(height: 48),
                AdText.headline('Air Drum', fontWeight: FontWeight.bold),
                const SizedBox(height: 48),
                _NavItem(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'Back',
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.bluetooth_searching_rounded,
                  label: 'Magic Setup',
                  isActive: true,
                  onTap: () {},
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AdText.label(
                    'v1.1.0',
                    color: cs.onSurface.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // ── Wizard Content ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth_searching_rounded,
                          color: cs.primary, size: 22),
                      const SizedBox(width: 12),
                      AdText.headline('Magic Setup',
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step indicators
                          Obx(() => _StepIndicator(
                                currentStep: controller.wizardStep.value,
                              )),
                          const SizedBox(height: 32),

                          // Step 1
                          Obx(() => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: controller.wizardStep.value == 0
                                    ? _Step1(controller: controller)
                                    : _Step2(controller: controller),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator bar
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StepDot(
          number: '1',
          label: 'Network Details',
          isDone: currentStep > 0,
          isActive: currentStep == 0,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: currentStep > 0
                  ? cs.primary
                  : cs.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        _StepDot(
          number: '2',
          label: 'Select Stick',
          isDone: false,
          isActive: currentStep == 1,
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String number;
  final String label;
  final bool isDone;
  final bool isActive;

  const _StepDot({
    required this.number,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = isActive || isDone;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? cs.primary : cs.secondary,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  number,
                  style: TextStyle(
                    color: active ? Colors.white : cs.onSurface.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        AdText.label(
          label,
          color: active ? cs.onSurface : cs.onSurface.withOpacity(0.35),
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Network details
// ─────────────────────────────────────────────────────────────────────────────

class _Step1 extends StatefulWidget {
  final SetupController controller;
  const _Step1({required this.controller});

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  bool get _canContinue =>
      widget.controller.ssidController.text.trim().isNotEmpty &&
      widget.controller.ipController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.ssidController.addListener(_rebuild);
    widget.controller.ipController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.ssidController.removeListener(_rebuild);
    widget.controller.ipController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.title('Network Details', fontWeight: FontWeight.w600),
        const SizedBox(height: 4),
        AdText.body(
          'Enter the WiFi network your sticks should connect to, '
          'and your computer\'s local IP address.',
          color: cs.onSurface.withOpacity(0.5),
        ),
        const SizedBox(height: 24),

        _AppCard(
          child: Column(
            children: [
              _AppField(
                controller: widget.controller.ssidController,
                hint: 'WiFi Name (SSID)',
                label: 'Network Name',
                icon: Icons.wifi_rounded,
              ),
              const SizedBox(height: 14),
              _AppField(
                controller: widget.controller.passController,
                hint: 'Leave blank if open network',
                label: 'WiFi Password',
                icon: Icons.lock_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 14),
              _AppField(
                controller: widget.controller.ipController,
                hint: 'e.g. 192.168.1.5',
                label: 'Your Computer\'s IP',
                icon: Icons.computer_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Helper hint
        if (!_canContinue)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: cs.onSurface.withOpacity(0.35)),
                const SizedBox(width: 6),
                AdText.label(
                  'WiFi name and computer IP are required to continue.',
                  color: cs.onSurface.withOpacity(0.35),
                ),
              ],
            ),
          ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: AdButton.filled(
            label: 'Continue & Scan for Sticks',
            icon: Icons.arrow_forward_rounded,
            onPressed: _canContinue
                ? () {
                    widget.controller.wizardStep.value = 1;
                    widget.controller.startScan();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Scan & select stick
// ─────────────────────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final SetupController controller;
  const _Step2({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdText.title('Select a Stick', fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              AdText.body(
                'Tap a discovered stick to send your credentials.',
                color: cs.onSurface.withOpacity(0.5),
              ),
            ]),
            Obx(() => controller.isScanning.value
                ? const SizedBox.shrink()
                : AdButton.outlined(
                    label: 'Rescan',
                    icon: Icons.refresh_rounded,
                    onPressed: controller.startScan,
                  )),
          ],
        ),
        const SizedBox(height: 24),

        // Device list / empty state
        Obx(() {
          if (controller.isScanning.value) {
            return _ScanningPlaceholder();
          }
          if (controller.foundDevices.isEmpty) {
            return _EmptyState(onRescan: controller.startScan);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.foundDevices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final result = controller.foundDevices[index];
              return _StickTile(
                result: result,
                isConnecting: false,
                onTap: () => controller.configureStick(result.device),
              );
            },
          );
        }),

        const SizedBox(height: 24),

        // Status banner
        Obx(() => _StatusBanner(
              status: controller.setupStatus.value,
              done: controller.setupDone.value,
              isConnecting: controller.isConnecting.value,
            )),

        const SizedBox(height: 16),

        // Go back to edit credentials
        Obx(() => controller.setupDone.value
            ? const SizedBox.shrink()
            : TextButton.icon(
                onPressed: controller.isConnecting.value
                    ? null
                    : () => controller.wizardStep.value = 0,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Edit Network Details'),
              )),
      ],
    );
  }
}

class _ScanningPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: cs.primary),
            ),
            const SizedBox(height: 16),
            AdText.body('Scanning for AirDrum sticks…',
                color: cs.onSurface.withOpacity(0.5)),
            const SizedBox(height: 4),
            AdText.label('This takes about 6 seconds.',
                color: cs.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRescan;
  const _EmptyState({required this.onRescan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.bluetooth_disabled_rounded,
                size: 36, color: cs.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            AdText.body('No sticks found',
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.6)),
            const SizedBox(height: 6),
            AdText.label(
              'Make sure the stick is powered on and nearby.',
              color: cs.onSurface.withOpacity(0.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AdButton.outlined(
              label: 'Scan Again',
              icon: Icons.refresh_rounded,
              onPressed: onRescan,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.isActive
                ? cs.primary.withOpacity(0.15)
                : (_hovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 20,
                  color: widget.isActive
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.5)),
              const SizedBox(width: 12),
              AdText.body(
                widget.label,
                fontWeight:
                    widget.isActive ? FontWeight.bold : FontWeight.w500,
                color: widget.isActive
                    ? cs.primary
                    : cs.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final Widget child;
  const _AppCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.secondary),
      ),
      child: child,
    );
  }
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isPassword;

  const _AppField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.label(label, fontWeight: FontWeight.w600),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 14),
            prefixIcon:
                Icon(icon, color: cs.onSurface.withOpacity(0.4), size: 20),
            filled: true,
            fillColor: cs.secondary.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.secondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _StickTile extends StatefulWidget {
  final dynamic result;
  final bool isConnecting;
  final VoidCallback onTap;

  const _StickTile(
      {required this.result,
      required this.isConnecting,
      required this.onTap});

  @override
  State<_StickTile> createState() => _StickTileState();
}

class _StickTileState extends State<_StickTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? cs.primary.withOpacity(0.08) : cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  _hovered ? cs.primary.withOpacity(0.4) : cs.secondary,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.speaker_rounded,
                    color: cs.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdText.body(
                      widget.result.device.platformName.isEmpty
                          ? 'AirDrum Stick'
                          : widget.result.device.platformName,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 2),
                    AdText.label(
                      'Tap to configure',
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: cs.onSurface.withOpacity(0.25), size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  final bool done;
  final bool isConnecting;

  const _StatusBanner({
    required this.status,
    required this.done,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final color = done ? Colors.green.shade400 : cs.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (isConnecting)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: color),
              ),
            ),
          Expanded(child: AdText.body(status, color: color)),
        ],
      ),
    );
  }
}
