# luckfox-pico

Linux system based on Alpine for Luckfox Pico Pro Max (SPI flash).
Added [zabbix_ina226](https://github.com/lugamodder/zabbix_ina226) scripts and zabbix-agent.
It is assumed that INA226 module (with shunt 0.002 ohm) connected on I2C-3, and AC-loss sensor connected on GPIO2_A2.

## Downloads

Check out
[Github Actions Artifacts](https://github.com/lugamodder/luckfox-pico/actions/workflows/main.yml)
for latest Alpine Linux images.

## Flashing

See
[the official docs](https://wiki.luckfox.com/Luckfox-Pico/Linux-MacOS-Burn-Image)
for instructions on flashing `update.img` to your Pico board.

For example, to flash Pico Pro Max boards,
connect the board to your computer while pressing _BOOT_ key, then execute
```bash
sudo ./upgrade_tool uf pico-pro-max-sysupgrade.img
```

## Setting Up

SSH enabled.
The default username/password is `root:luckfox`.

UART serial debug port is enabled,
and `sshd` server is installed and enabled as well.

To connect to it via ethernet, simply do
```bash
ssh root@<ip_of_pico_board>
```

### Ethernet/RNDIS

DHCP client enabled on eth0.
Persistent MAC address generated by script on startup, based on board serial number.

RNDIS enabled.
To connect to your Pico through RNDIS,
check out [the official guide](https://wiki.luckfox.com/Luckfox-Pico/SSH-Telnet-Login/).

The board's  IP is `172.32.0.93`.

The DHCP server is enabled on USB0, so your PC will receive the IP address automatically.

