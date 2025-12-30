"""
purchase_item API - [테이블 설명] CRUD
개별 실행: python purchase_item.py

작성자: yeeun
작성일: 20251230

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
ipAddress = "172.16.250.175"

#"127.0.0.1"
port = 8001


# ============================================
# 모델 정의
# ============================================
# TODO: 테이블 컬럼에 맞게 모델 정의
# - id는 Optional[int] = None 으로 정의 (자동 생성)
# - 필수 컬럼은 타입만 지정 (예: cEmail: str)
# - 선택 컬럼은 Optional로 지정 (예: cProfileImage: Optional[bytes] = None)
class YourModel(BaseModel):
    id: Optional[int] = None
    # TODO: 컬럼 추가


# ============================================
# 전체 조회 (Read All)
# ============================================
# TODO: 전체 목록 조회 API 구현
# - 이미지 BLOB 컬럼은 제외하고 조회
# - ORDER BY id 정렬
@app.get("/select_purchase_item")
async def select_all():
    conn = connect_db()
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT b_seq, br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_tnum
        FROM purchase_item
        ORDER BY b_seq
    """)
    
    rows = curs.fetchall()
    conn.close()
    
    # TODO: 결과 매핑
    result = [{
      'b_seq': row[0],
      'br_seq':row[1], 
      'u_seq':row[2], 
      'p_seq':row[3], 
      'b_price':row[4], 
      'b_quantity':row[5],
      'b_date':str(row[6]),
      'b_tnum':row[7]
    } for row in rows]
    
    return {"results": result}


# ============================================
# 단일 조회 (Read One)
# ============================================
# TODO: ID로 단일 조회 API 구현
# - 존재하지 않으면 에러 응답
@app.get("/select_purchase_item/{b_seq}")
async def select_one(b_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT b_seq, br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_tnum
        FROM purchase_item
        WHERE b_seq = %s
    """, (b_seq,))
    
    row = curs.fetchone()
    conn.close()
    
    if row is None:
        return {"result": "Error", "message": "select_purchase_item not found"}
    
    # TODO: 결과 매핑
    result = {
      'b_seq': row[0],
      'br_seq':row[1], 
      'u_seq':row[2], 
      'p_seq':row[3], 
      'b_price':row[4], 
      'b_quantity':row[5],
      'b_date':str(row[6]),
      'b_tnum':row[7]
    }
    return {"result": result}


# ============================================
# 추가 (Create)
# ============================================
# TODO: 새 레코드 추가 API 구현
# - Form 데이터로 받기: 파라미터 = Form(...)
# - 성공 시 생성된 ID 반환
# - 에러 처리 필수
@app.post("/insert_purchase_item")
async def insert_one(
    br_seq: int = Form(...),
    u_seq: int = Form(...),
    p_seq: int = Form(...),
    b_price: int = Form(...),
    b_quantity: int = Form(...),
    b_date: str = Form(...),
    b_tnum: int = Form(...)

    # TODO: Form 파라미터 정의
    # 예: columnName: str = Form(...)
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # TODO: SQL 작성
        sql = """
            INSERT INTO purchase_item (br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_tnum) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_tnum))
        
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        
        return {"result": "OK", "id": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 수정 (Update)
# ============================================
# TODO: 레코드 수정 API 구현
# - 이미지 BLOB이 있는 경우: 이미지 제외/포함 두 가지 API 구현 권장
@app.post("/update_purchase_item")
async def update_one(
    b_seq: int = Form(...),
    br_seq: int = Form(...),
    u_seq: int = Form(...),
    p_seq: int = Form(...),
    b_price: int = Form(...),
    b_quantity: int = Form(...),
    b_date: str = Form(...),
    b_tnum: int = Form(...)
    # TODO: 수정할 Form 파라미터 정의
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # TODO: SQL 작성
        sql = """
            UPDATE purchase_item
            SET br_seq=%s, u_seq=%s, p_seq=%s, b_price=%s, b_quantity=%s, b_date=%s, b_tnum=%s
            WHERE b_seq=%s
        """
        curs.execute(sql, (br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_tnum, b_seq))
        #1=pbid
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 삭제 (Delete)
# ============================================
# TODO: 레코드 삭제 API 구현
# - FK 참조 시 삭제 실패할 수 있음 (에러 처리)
@app.delete("/delete_purchase_item/{b_seq}")
async def delete_one(b_seq: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        sql = "DELETE FROM purchase_item WHERE b_seq=%s"
        curs.execute(sql, (b_seq,))
        
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# [선택] 이미지 조회 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
# TODO: 이미지 바이너리 직접 반환
# - Response 객체 사용
# - media_type: "image/jpeg" 또는 "image/png"
# @app.get("/view_[테이블명]_image/{item_id}")
# async def view_image(item_id: int):
#     try:
#         conn = connect_db()
#         curs = conn.cursor()
#         curs.execute("SELECT [이미지컬럼] FROM [테이블명] WHERE id = %s", (item_id,))
#         row = curs.fetchone()
#         conn.close()
#         
#         if row is None:
#             return {"result": "Error", "message": "Not found"}
#         
#         if row[0] is None:
#             return {"result": "Error", "message": "No image"}
#         
#         return Response(
#             content=row[0],
#             media_type="image/jpeg",
#             headers={"Cache-Control": "no-cache"}
#         )
#     except Exception as e:
#         return {"result": "Error", "errorMsg": str(e)}


# ============================================
# [선택] 이미지 업데이트 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
# TODO: 이미지만 별도로 업데이트
# - UploadFile = File(...) 사용
# @app.post("/update_[테이블명]_image")
# async def update_image(
#     item_id: int = Form(...),
#     file: UploadFile = File(...)
# ):
#     try:
#         image_data = await file.read()
#         
#         conn = connect_db()
#         curs = conn.cursor()
#         sql = "UPDATE [테이블명] SET [이미지컬럼]=%s WHERE id=%s"
#         curs.execute(sql, (image_data, item_id))
#         conn.commit()
#         conn.close()
#         
#         return {"result": "OK"}
#     except Exception as e:
#         return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 개별 실행
# ============================================
if __name__ == "__main__":
    import uvicorn
    print(f"🚀 [product] API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)

