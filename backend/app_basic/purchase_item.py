"""
[PurchaseItem] API - 주문 항목 CRUD
개별 실행: python app_basic/purchase_item.py

작성자: 정진석
작성일: 2025-12-29

수정 이력:
| 날짜 | 작성자 | 내용 |
|------|--------|------|
"""

from fastapi import FastAPI, Form, Response, UploadFile, File
from pydantic import BaseModel
from typing import Optional
from database.connection import connect_db

app = FastAPI()
ipAddress = "127.0.0.1"
port = 8001

class PurchaseItemModel(BaseModel):
    id: Optional[int] = None
    pid: int
    pcid: int
    pcQuantity: int
    pcStatus: str

@app.get("/select_purchaseitems")
async def select_all():
    conn = connect_db()
    curs = conn.cursor()

    curs.execute("""
        SELECT id, pid, pcid, pcQuantity, pcStatus
        FROM PurchaseItem
        ORDER BY id
    """)

    rows = curs.fetchall()
    conn.close()

    result = [{
        "id": row[0],
        "pid": row[1],
        "pcid": row[2],
        "pcQuantity": row[3],
        "pcStatus": row[4]
    } for row in rows]

    return {"results": result}

@app.get("/select_purchaseitem/{item_id}")
async def select_one(item_id: int):
    conn = connect_db()
    curs = conn.cursor()

    curs.execute("""
        SELECT id, pid, pcid, pcQuantity, pcStatus
        FROM PurchaseItem
        WHERE id = %s
    """, (item_id,))

    row = curs.fetchone()
    conn.close()

    if row is None:
        return {"result": "Error", "message": "PurchaseItem not found"}

    result = {
        "id": row[0],
        "pid": row[1],
        "pcid": row[2],
        "pcQuantity": row[3],
        "pcStatus": row[4]
    }
    return {"result": result}

@app.post("/insert_purchaseitem")
async def insert_one(
    pid: int = Form(...),
    pcid: int = Form(...),
    pcQuantity: int = Form(...),
    pcStatus: str = Form(...)
):
    try:
        conn = connect_db()
        curs = conn.cursor()

        sql = """
            INSERT INTO PurchaseItem (pid, pcid, pcQuantity, pcStatus)
            VALUES (%s,%s,%s,%s)
        """
        curs.execute(sql, (pid, pcid, pcQuantity, pcStatus))

        conn.commit()
        new_id = curs.lastrowid
        conn.close()

        return {"result": "OK", "id": new_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

@app.post("/update_purchaseitem")
async def update_one(
    item_id: int = Form(...),
    pcQuantity: int = Form(...),
    pcStatus: str = Form(...)
):
    try:
        conn = connect_db()
        curs = conn.cursor()

        sql = """
            UPDATE PurchaseItem
            SET pcQuantity=%s, pcStatus=%s
            WHERE id=%s
        """
        curs.execute(sql, (pcQuantity, pcStatus, item_id))

        conn.commit()
        conn.close()

        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

@app.delete("/delete_purchaseitem/{item_id}")
async def delete_one(item_id: int):
    try:
        conn = connect_db()
        curs = conn.cursor()

        curs.execute("DELETE FROM PurchaseItem WHERE id=%s", (item_id,))
        conn.commit()
        conn.close()

        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

if __name__ == "__main__":
    import uvicorn
    print("🚀 PurchaseItem API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)