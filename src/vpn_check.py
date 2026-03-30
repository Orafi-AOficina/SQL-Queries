"""
vpn_check.py — Módulo de pré-requisito VPN para scripts de automação

Uso em outros scripts:
    from vpn_check import ensure_vpn
    ensure_vpn()   # levanta RuntimeError se não conseguir conectar

Ou como wrapper de linha de comando:
    python vpn_check.py && python meu_script.py
"""

import subprocess
import sys
from pathlib import Path


VPN_HOST      = "10.10.0.5"
VPN_SCRIPT    = Path(__file__).parent / "vpn_connect.py"
CONNECT_TIMEOUT = 60


def is_connected() -> bool:
    result = subprocess.run(
        ["ping", "-n", "2", "-w", "1000", VPN_HOST],
        capture_output=True,
    )
    return result.returncode == 0


def ensure_vpn(timeout: int = CONNECT_TIMEOUT) -> None:
    """
    Garante que a VPN está conectada antes de prosseguir.
    Chama vpn_connect.py automaticamente se necessário.
    Levanta RuntimeError se não conseguir conectar.
    """
    if is_connected():
        return

    print("[vpn_check] VPN não conectada — tentando conectar automaticamente...")
    result = subprocess.run(
        [sys.executable, str(VPN_SCRIPT), "--timeout", str(timeout)],
        timeout=timeout + 30,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"[vpn_check] Falha ao conectar VPN (código {result.returncode}). "
            "Verifique se o FortiClient está instalado e configurado."
        )


if __name__ == "__main__":
    try:
        ensure_vpn()
        print("[OK] VPN pronta.")
        sys.exit(0)
    except RuntimeError as e:
        print(f"[ERRO] {e}")
        sys.exit(1)
