
from fastapi import FastAPI
from app.models import DeviceId, TimeRange
from app.controller import abrir_puerta, generar_contraseña_temporal

app = FastAPI()

@app.post("/abrir-puerta")
def api_abrir_puerta(req: DeviceId):
    return abrir_puerta(req.device_id)

@app.post("/generar-password")
def api_generar_password(req: TimeRange):
    return generar_contraseña_temporal(req.device_id, req.desde, req.hasta)
