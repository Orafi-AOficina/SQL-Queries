from src.vpn_check import ensure_vpn


def main():
    ensure_vpn()
    print("VPN pronta. Ambiente SQL-Queries inicializado.")


if __name__ == "__main__":
    main()
