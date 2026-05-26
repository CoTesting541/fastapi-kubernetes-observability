import os
import psycopg2
import logging
import time

logger = logging.getLogger("repository")

db = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST"),
    database=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD"),
)


def create_user(username: str):

    cursor = db.cursor()

    cursor.execute("INSERT INTO users (username) VALUES (%s) RETURNING id", (username,))

    user_id = cursor.fetchone()[0]
    db.commit()

    return {"id": user_id, "username": username}


def get_user(user_id: int):

    start = time.time()

    cursor = db.cursor()
    cursor.execute("SELECT id, username FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    duration = (time.time() - start) * 1000
    logger.info(f"DB get_user completed in {duration:.2f}ms")

    if not user:
        return {"error": "user not found"}

    return user


def update_user(user_id: int, username: str):
    cursor = db.cursor()
    cursor.execute("UPDATE users SET username = %s WHERE id = %s", (username, user_id))
    db.commit()
    return cursor.rowcount


def delete_user(user_id: int):

    cursor = db.cursor()

    cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))

    db.commit()

    return cursor.rowcount
