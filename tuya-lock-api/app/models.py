from pydantic import BaseModel
from datetime import datetime

class DeviceId(BaseModel):
    device_id: str

class TimeRange(BaseModel):
    device_id: str
    desde: datetime
    hasta: datetime
