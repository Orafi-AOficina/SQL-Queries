"""
vpn_connect.py — Automação de conexão FortiClient VPN via pyautogui
Uso: python vpn_connect.py [--force] [--timeout 60]

--force   : tenta conectar mesmo que ping inicial seja positivo
--timeout : segundos aguardando conexão após clicar (padrão: 60)
"""

import subprocess
import sys
import time
import argparse

try:
    import pyautogui
    import pygetwindow as gw
except ImportError:
    print("[ERRO] Instale as dependências: pip install pyautogui pygetwindow")
    sys.exit(1)


# ── Configurações ──────────────────────────────────────────────────────────────

VPN_HOST       = "10.10.0.5"          # IP interno para verificar conectividade
FORTICLIENT_EXE = r"C:\Program Files\Fortinet\FortiClient\FortiClient.exe"

# Coordenadas do botão "Conectar" RELATIVAS ao canto superior-esquerdo da janela
# Medidas com base no screenshot: janela 883×704, botão aprox. (437, 554)
BTN_CONNECT_REL = (437, 554)

# Tolerância: se a janela tiver tamanho diferente, ajusta proporcionalmente
WINDOW_REF_SIZE = (883, 704)   # largura × altura de referência

pyautogui.FAILSAFE = True      # mover mouse para canto superior-esquerdo aborta


# ── Helpers ───────────────────────────────────────────────────────────────────

def ping(host: str, count: int = 2) -> bool:
    """Retorna True se o host responder ao ping."""
    result = subprocess.run(
        ["ping", "-n", str(count), "-w", "1000", host],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0


def is_connected() -> bool:
    return ping(VPN_HOST)


def find_forticlient_window():
    """Retorna a janela do FortiClient ou None."""
    titles = gw.getAllTitles()
    for title in titles:
        if "forticlient" in title.lower() or "forti" in title.lower():
            wins = gw.getWindowsWithTitle(title)
            if wins:
                return wins[0]
    return None


def open_forticlient():
    """Abre o FortiClient se não estiver aberto."""
    print("[INFO] Abrindo FortiClient...")
    subprocess.Popen([FORTICLIENT_EXE])
    for _ in range(20):
        time.sleep(1)
        win = find_forticlient_window()
        if win:
            print(f"[INFO] Janela encontrada: '{win.title}'")
            return win
    return None


def bring_to_front(win) -> bool:
    """Traz a janela para frente e restaura se minimizada."""
    try:
        if win.isMinimized:
            win.restore()
        win.activate()
        time.sleep(0.5)
        return True
    except Exception as e:
        print(f"[AVISO] Não foi possível ativar janela: {e}")
        return False


def click_connect(win) -> None:
    """Clica no botão Conectar usando coordenadas relativas à janela."""
    # Calcula coordenada absoluta ajustando pela escala real da janela
    scale_x = win.width  / WINDOW_REF_SIZE[0]
    scale_y = win.height / WINDOW_REF_SIZE[1]

    rel_x = int(BTN_CONNECT_REL[0] * scale_x)
    rel_y = int(BTN_CONNECT_REL[1] * scale_y)

    abs_x = win.left + rel_x
    abs_y = win.top  + rel_y

    print(f"[INFO] Janela: {win.left},{win.top} | {win.width}×{win.height}")
    print(f"[INFO] Clicando em ({abs_x}, {abs_y}) -> relativo ({rel_x}, {rel_y})")

    pyautogui.moveTo(abs_x, abs_y, duration=0.3)
    time.sleep(0.2)
    pyautogui.click()


def wait_for_connection(timeout: int) -> bool:
    """Aguarda conexão por até `timeout` segundos."""
    print(f"[INFO] Aguardando conexão (timeout: {timeout}s)...", end="", flush=True)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if is_connected():
            print(" OK")
            return True
        print(".", end="", flush=True)
        time.sleep(2)
    print(" TIMEOUT")
    return False


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Conecta FortiClient VPN automaticamente")
    parser.add_argument("--force",   action="store_true", help="Força reconexão mesmo se já conectado")
    parser.add_argument("--timeout", type=int, default=60, help="Segundos aguardando após clicar (padrão: 60)")
    args = parser.parse_args()

    # 1. Verificar se já está conectado
    if not args.force and is_connected():
        print(f"[OK] VPN já conectada — {VPN_HOST} acessível.")
        sys.exit(0)

    print(f"[INFO] VPN não conectada. Iniciando automação...")

    # 2. Localizar ou abrir o FortiClient
    win = find_forticlient_window()
    if win is None:
        win = open_forticlient()
        if win is None:
            print("[ERRO] Não foi possível abrir o FortiClient.")
            sys.exit(2)
        time.sleep(2)   # aguarda carregamento da UI
    else:
        print(f"[INFO] FortiClient já aberto: '{win.title}'")

    # 3. Trazer janela para frente
    bring_to_front(win)
    time.sleep(0.5)

    # 4. Clicar no botão Conectar
    click_connect(win)

    # 5. Aguardar conexão
    if wait_for_connection(args.timeout):
        print("[OK] VPN conectada com sucesso.")
        sys.exit(0)
    else:
        print("[ERRO] VPN não conectou dentro do tempo esperado.")
        sys.exit(3)


if __name__ == "__main__":
    main()
