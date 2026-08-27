# ── ThinkPad T14 Gen 2i — suspend/resume safety net ─────────────────────────
#
# Written after a hard hang on 2026-08-25: the previous boot's journal ended
# mid-suspend at "PM: suspend entry (s2idle)" with no resume log ever
# appearing — a full kernel/firmware freeze, not a userspace crash. This
# hardware only supports s2idle (no real S3), which is more prone to this
# class of hang than deep sleep.
#
# BIOS/EC were flashed current via fwupd on 2026-08-27 (N34ET50W -> N34ET71W,
# EC 0.1.41 -> 0.1.45) — the highest-confidence fix for the hang itself.
#
# This file deliberately holds ONLY inert/safety-net changes: things that
# don't alter suspend/resume behavior (microcode) or that only change what
# happens *after* a hang starts (hibernate fallback), so if anything odd
# happens post-rebuild it can't be attributed to these. Two more targeted
# changes — disabling NVMe APST and blacklisting the unused `xe` module —
# are parked on the `t14-power-management` branch and deliberately withheld
# unless the hang recurs post-firmware-update, so they can be tested one at
# a time rather than bundled in.

{ config, lib, pkgs, ... }:

{
  # Microcode was never actually being applied: hardware-configuration.nix
  # ties hardware.cpu.intel.updateMicrocode to enableRedistributableFirmware,
  # which nothing in this config sets. Intel has shipped microcode fixes for
  # Tiger Lake power-management errata since this machine's original image.
  # Pure upside, no behavioral tradeoff.
  hardware.enableRedistributableFirmware = true;

  # ── logind: lid/power handling + suspend-then-hibernate ────────────────
  #
  # suspend-then-hibernate suspends immediately (fast, low power) but if the
  # machine stays suspended past the delay below, it wakes just enough to
  # write a hibernation image to swap and powers off fully. That bounds how
  # long the system spends in the fragile s2idle state and gives a real
  # "fully off" fallback if s2idle misbehaves again — hibernation from a
  # power-off state doesn't depend on s2idle at all.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "poweroff";
    HandleSuspendKey = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";

  # ── Hibernate resume target ─────────────────────────────────────────────
  # Swap partition is 34GB against 31GB RAM — enough headroom for a
  # hibernation image. This is what wires up resume= for the kernel.
  boot.resumeDevice = "/dev/disk/by-uuid/2ba9bbb1-a3e8-4d3e-a625-c4e49906ca97";

  # ── Hibernate on low/critical battery ───────────────────────────────────
  # Belt-and-suspenders alongside suspend-then-hibernate above: if the
  # battery is nearly dead, go straight to hibernate rather than risk losing
  # unsaved state to a suspended-then-drained battery.
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };
}
