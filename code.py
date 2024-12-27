import io
import os
import time
import adafruit_imageload
import board
import displayio
import adafruit_requests
import wifi
import adafruit_connection_manager
import supervisor
from adafruit_hx8357 import HX8357
import json

try:
	# noinspection PyUnresolvedReferences
	from typing import Optional
except ImportError:
	pass

supervisor.runtime.autoreload = False

# watchdog auto-reboot
import watchdog
import microcontroller
microcontroller.watchdog.timeout = 60
microcontroller.watchdog.mode = watchdog.WatchDogMode.RESET
microcontroller.watchdog.feed()

print("Initializing display...")
displayio.release_displays() # for soft reboots
# noinspection PyUnresolvedReferences
display_bus = displayio.FourWire(board.SPI(), command = board.D6, chip_select = board.D10)
display = HX8357(display_bus, width = 480, height = 320, rotation = 180)
# noinspection PyTypeChecker
display.root_group = None # suppress console on screen

print("Connecting...")
available_networks = list(wifi.radio.start_scanning_networks())
known_networks = json.load(open("/wifi.json"))

ssid = None
password = None
for available_network in available_networks:
	for known_network in known_networks:
		if known_network["ssid"] == available_network.ssid:
			ssid = available_network.ssid
			password = known_network["password"]
			break

if not ssid:
	raise RuntimeError("WiFi not found")

wifi.radio.connect(
	ssid = ssid,
	password = password,
	timeout = 15
)
ssl_context = adafruit_connection_manager.get_radio_ssl_context(wifi.radio)
pool = adafruit_connection_manager.get_radio_socketpool(wifi.radio)
requests = adafruit_requests.Session(pool, ssl_context)

print("Connected")
print(f"SSID: {wifi.radio.ap_info.ssid}")
print(f"Radio: RSSI {wifi.radio.ap_info.rssi}, ch. {wifi.radio.ap_info.channel}, tx. {wifi.radio.tx_power} dBm")
print(f"IP: {wifi.radio.ipv4_address}")

def refresh(last_etag: str = None) -> Optional[str]:
	print("Downloading image...")
	response = requests.get(os.getenv("IMAGE_ENDPOINT"))
	etag = response.headers["etag"] if "etag" in response.headers else None

	if etag is not None and last_etag == etag:
		print("Not refreshing: ETag didn't change")
		return etag

	image_data = response.content
	print(f"Done, {len(image_data)} bytes")

	print("Rendering...")
	# noinspection PyTypeChecker
	bitmap, palette = adafruit_imageload.load(io.BytesIO(image_data))
	group = displayio.Group()
	tile_grid = displayio.TileGrid(bitmap, pixel_shader = palette)
	tile_grid.flip_x = True
	tile_grid.flip_y = True
	group.append(tile_grid)
	display.root_group = group

	print(f"Done rendering; ETag was: {etag}")

	return etag

last_etag = refresh()

start = time.monotonic()
while True:
	time.sleep(10)
	microcontroller.watchdog.feed()

	# noinspection PyTypeChecker
	if time.monotonic() - start >= os.getenv("REFRESH_INTERVAL_SECONDS"):
		print("Wait time expired, refreshing...")
		last_etag = refresh(last_etag)
		start = time.monotonic()