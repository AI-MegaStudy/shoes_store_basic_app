"""
[ProductBase] API - 제품 기본 정보 CRUD
개별 실행: python product_base.py

작성자: 정진석
작성일: 2025-12-29

수정 이력:
| 날짜 | 작성자 | 내용 |
|------|--------|------|
|      |        |      |
"""

from fastapi import FastAPI, Form, UploadFile, File, Response
from pydantic import BaseModel
from typing import Optional
from database.connection import connect_db

app = FastAPI()
ipAddress = "127.0.0.1"
port = 8000

class ProductBaseModel(BaseModel):
    id: Optional[int] = None
    pName: str
    pDescription: Optional[str] = None
    pColor: Optional[str] = None
    pGender: Optional[str] = None
    pStatus: Optional[str] = None
    pFeatureType: Optional[str] = None
    pCategory: Optional[str] = None
    pModelNumber: Optional[str] = None

@app.get("/select_productbase")
async def select_all():
    conn = connect_db()
    curs = conn.cursor()

    curs.execute("""
        SELECT id, pName, pDescription, pColor, pGender, pStatus, pFeatureType, pCategory, pModelNumber
        FROM ProductBase
        ORDER BY id
    """)

    rows = curs.fetchall()
    conn.close()

    result = [{
        'id': row[0],
        'pName': row[1],
        'pDescription': row[2],
        'pColor': row[3],
        'pGenderd': row[4],
        'pStatus': row[5],
        'pFeatureType': row[6],
        'pCategory': row[7],
        'pModelNumber': row[8],
    } for row in rows]

    return {"results": result}

@app.get("/select_productbase/{item_id}")
async def select_one(item_id:int):
    conn = connect_db()
    curs = conn.cursor()

    curs.execute("""
        SELECT id, pName, pDescription, pColor, pGender, pStatus, pFeatureType, pCategory, pModelNumber
        FROM ProductBase
        WHERE id = %s
    """, (item_id,))

    row = curs.fetchone()
    conn.close()

    if row is None:
        return {"result": "Error", "message": "ProductBase not found"}
    
    result = {
        'id': row[0],
        'pName': row[1],
        'pDescription': row[2],
        'pColor': row[3],
        'pGenderd': row[4],
        'pStatus': row[5],
        'pFeatureType': row[6],
        'pCategory': row[7],
        'pModelNumber': row[8],
    }
    return {"result": result}

@app.post("/insert_ProductBase")
async def insert_one(
    pName: str = Form(...),
    pDescription: Optional[str] = Form(None),
    pColor: Optional[str] = Form(None),
    pGender: Optional[str] = Form(None),
    pStatus: Optional[str] = Form(None),
    pFeatureType: Optional[str] = Form(None),
    pCategory: Optional[str] = Form(None),
    pModelNumber: Optional[str] = Form(None),
):
    try:
        conn = connect_db()
        curs = conn.cursor()

        sql = """
            INSERT INTO ProductBase
            pName, pDescription, pColor, pGender, pStatus, pFeatureType, pCategory, pModelNumber)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """
        curs.execute(sql, (pName, pDescription, pColor, pGender, pStatus, pFeatureType, pCategory, pModelNumber))

        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()

        return {"result": "OK", "id": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

@app.post("/update_ProductBase")
async def update_one(
    item_id: int = Form(...),
    pName: str = Form(...),
    pDescription: Optional[str] = Form(None),
    pColor: Optional[str] = Form(None),
    pGender: Optional[str] = Form(None),
    pStatus: Optional[str] = Form(None),
    pFeatureType: Optional[str] = Form(None),
    pCategory: Optional[str] = Form(None),
    pModelNumber: Optional[str] = Form(None),
):
    try:
        conn = connect_db()
        curs = conn.cursor()

        sql = """
            UPDATE ProductBase
            ST pName=%s, pDescription=%s, pColor=%s, pGender=%s, pStatus=%s, pFeatureType=%s, pCategory=%s, pModelNumber=%s
        """
        curs.execute(sql, (pName, pDescription, pColor, pGender, pStatus, pFeatureType, pCategory, pModelNumber, item_id))

        conn.commit()
        conn.close()

        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

@app.delete("/delete_ProductBase/{item_id}")
async def delete_one(item_id: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        sql = "DELETE FROM ProductBase WHERE id=%s"
        curs.execute(sql, (item_id,))
        
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

if __name__ == "__main__":
    import uvicorn
    print(f"🚀 ProductBase API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)