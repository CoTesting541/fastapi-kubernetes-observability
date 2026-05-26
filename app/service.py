import redis
import json
import os
import repository as repo
import logging


redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST"), port=6379, decode_responses=True
)

logger = logging.getLogger("service")


def create_user(username: str):

    user = repo.create_user(username)

    # IMPORTANT: no cache yet, but ensure no stale key exists
    redis_client.delete(f"user:{user['id']}")

    logger.info(f"User created: {user['id']}")
    return user


def get_user(user_id: int):
    cache_key = f"user:{user_id}"
    cached = redis_client.get(cache_key)

    if cached:
        logger.info(f"Cache hit for user {user_id}")
        return {"source": "redis", "data": json.loads(cached)}

    logger.info(f"Cache miss for user {user_id}")
    row = repo.get_user(user_id)
    logger.info(f"ROW TYPE: {type(row)} VALUE: {row}")
    if not row:
        logger.info(f"User not found: {user_id}")
        return None

    response = {"id": row[0], "username": row[1]}

    redis_client.setex(cache_key, 60, json.dumps(response))  # Cache for 60 seconds

    return response


def update_user(user_id: int, username: str):

    affected = repo.update_user(user_id, username)

    if affected == 0:
        return None

    redis_client.delete(f"user:{user_id}")

    return {"id": user_id, "username": username}


def delete_user(user_id: int):

    row = repo.delete_user(user_id)

    if row == 0:
        return None

    redis_client.delete(f"user:{user_id}")

    return {"message": "user deleted", "id": user_id}
