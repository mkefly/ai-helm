import logging
from fastapi import FastAPI

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("fastapi_app")

app = FastAPI(title="FastAPI with HPA", version="1.0.0")


@app.on_event("startup")
async def startup_event():
    logger.info("FastAPI app starting up")


@app.get("/health", tags=["system"])
def health():
    logger.debug("Health endpoint called")
    return {"status": "ok"}


@app.get("/ping", tags=["demo"])
def ping():
    logger.info("Ping endpoint called")
    return {"message": "pong"}
