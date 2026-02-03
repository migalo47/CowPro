# Imagen base oficial de Python
FROM python:3.11

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia todo el contenido del proyecto
COPY . .

# Instala las dependencias desde requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expone el puerto 8000 (FastAPI)
EXPOSE 8000

# Comando para ejecutar la app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
