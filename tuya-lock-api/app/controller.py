# app/controller.py
from tuya_iot import TuyaOpenAPI
import time
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import binascii
import random
from datetime import datetime

ACCESS_ID = "qpq9fadhrmkkmqfhhryr"
ACCESS_KEY = "6c76fe98f241481693b4d74b0b3b70cc"
ENDPOINT = "https://openapi.tuyaeu.com"

def init_openapi():
    openapi = TuyaOpenAPI(ENDPOINT, ACCESS_ID, ACCESS_KEY)
    token_response = openapi.get('/v1.0/token?grant_type=1')
    if token_response.get("success"):
        result = token_response["result"]
        class TokenInfo:
            def __init__(self, access_token, refresh_token, expire_time):
                self.access_token = access_token
                self.refresh_token = refresh_token
                self.expire_time = expire_time
        openapi.token_info = TokenInfo(result["access_token"], result["refresh_token"], result["expire_time"])
        return openapi
    else:
        raise Exception("❌ Error al autenticar con Tuya")

def abrir_puerta(device_id: str):
    openapi = init_openapi()
    commands = {"commands": [{"code": "automatic_lock", "value": True}]}
    response = openapi.post(f'/v1.0/iot-03/devices/{device_id}/commands', commands)
    return response

def obtener_ticket(openapi, device_id):
    response = openapi.post(f'/v1.0/devices/{device_id}/door-lock/password-ticket')
    if response.get("success"):
        return response["result"]["ticket_id"], response["result"]["ticket_key"]
    return None, None

def obtener_clave_original(ticket_key, access_secret):
    cipher = AES.new(access_secret.encode("utf-8"), AES.MODE_ECB)
    padded_plaintext = cipher.decrypt(binascii.unhexlify(ticket_key))
    return unpad(padded_plaintext, AES.block_size).decode()

def cifrar_contraseña(password: str, original_key: str) -> str:
    cipher = AES.new(original_key.encode("utf-8"), AES.MODE_ECB)
    padded_plaintext = pad(password.encode(), AES.block_size)
    encrypted = cipher.encrypt(padded_plaintext)
    return binascii.hexlify(encrypted).decode().upper()

def generar_contraseña_temporal(device_id: str, desde: datetime, hasta: datetime):
    openapi = init_openapi()
    password = str(random.randint(100000, 999999))
    ticket_id, ticket_key = obtener_ticket(openapi, device_id)
    if not ticket_id:
        return {"error": "No se pudo obtener el ticket"}

    original_key = obtener_clave_original(ticket_key, ACCESS_KEY)
    password_encrypted = cifrar_contraseña(password, original_key)

    params = {
        "password": password_encrypted,
        "password_type": "ticket",
        "ticket_id": ticket_id,
        "effective_time": int(desde.timestamp()),
        "invalid_time": int(hasta.timestamp()),
        "name": "TempPass",
        "type": 1
    }

    response = openapi.post(f'/v1.0/devices/{device_id}/door-lock/temp-password', params)
    return {
        "codigo": password,
        "inicio": desde.isoformat(),
        "fin": hasta.isoformat(),
        "respuesta": response
    }
