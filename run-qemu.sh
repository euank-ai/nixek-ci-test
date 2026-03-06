#!/usr/bin/env bash
# Run a nixek-ci job locally in QEMU
# Usage: ./run-qemu.sh [job-name]
# Default job: hello-world
set -eux -o pipefail

export PATH="/run/current-system/sw/bin:$PATH"
JOB_NAME="${1:-hello-world}"
NIX="nix --extra-experimental-features nix-command\ flakes"

echo "=== Evaluating job: ${JOB_NAME} ==="
STEPS=$($NIX eval --impure --json ".#ci.jobs.${JOB_NAME}" \
  --apply 'f: let job = f {}; in builtins.map (s: { inherit (s) name command; }) job.steps')

echo "=== Building QEMU image ==="
$NIX build --impure \
  --expr "let flake = builtins.getFlake (builtins.toString ./.); job = flake.ci.jobs.\"${JOB_NAME}\" {}; in job.machine.qemu" \
  -o ./qemu-image

mkdir -p ./run-config
cat > ./run-config/config.json <<EOF
{
  "name": "${JOB_NAME}",
  "job_id": "local-$(date +%s)",
  "steps": ${STEPS}
}
EOF

echo "=== Config ==="
cat ./run-config/config.json

rm -f ./run-overlay.qcow2
$NIX shell nixpkgs#qemu_kvm -c bash -c '
qemu-img create -b ./qemu-image/nixos.qcow2 -F qcow2 -f qcow2 ./run-overlay.qcow2
trap "rm -f ./run-overlay.qcow2" EXIT
echo "=== Booting QEMU VM ==="
timeout 120 qemu-system-x86_64 -enable-kvm \
  -drive file=./run-overlay.qcow2,if=virtio \
  -m 2048 -smp 2 \
  -fsdev local,security_model=none,id=fsdev0,path='"$(pwd)"'/run-config,readonly=on \
  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=nixek-config \
  -nographic -no-reboot
'
