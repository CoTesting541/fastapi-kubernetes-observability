from fastapi import FastAPI
import service as svc
import logging
import time

app = FastAPI()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("user-service")


@app.get("/")
def root():
    return {"status": "healthy"}


@app.post("/users")
def create_user(username: str):
    return svc.create_user(username)


@app.get("/users/{user_id}")
def get_user(user_id: int):
    result = svc.get_user(user_id)
    return result or {"error": "user not found"}


@app.put("/users/{user_id}")
def update_user(user_id: int, username: str):
    result = svc.update_user(user_id, username)
    return result or {"error": "user not found"}


@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    result = svc.delete_user(user_id)
    return result or {"error": "user not found"}


@app.middleware("http")
async def add_timing(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    logger.info(f"{request.method} {request.url} completed in {duration:.2f}s")
    return response
