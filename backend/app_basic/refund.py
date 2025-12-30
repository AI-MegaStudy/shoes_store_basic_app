"""
refund API - 고객 반품 테이블 CRUD
개별 실행: python [파일명].py

작성자: 임소연
작성일: 2025-12-30

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
@app.get("/select_refunds")
async def select_all():
    conn = connect_db()
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT ref_seq, pic_seq, s_seq, r.u_seq, created_at, ref_re_seq, ref_re_content, b_seq, u_name, b_date
        FROM refund as r
        inner join user as u
        on r.u_seq = u.u_seq
        inner join purchase_item as p
        on p.u_seq = u.u_seq
        ORDER BY ref_seq desc
    """) # 최신순 조회
    
    rows = curs.fetchall()
    conn.close()
    
    # TODO: 결과 매핑
    result = [{
        'ref_seq': row[0],
        'pic_seq': row[1],
        's_seq': row[2],
        'r.u_seq': row[3],
        'created_at': row[4],
        'ref_re_seq': row[5],
        'ref_re_content': row[6],
        'b_seq': row[7],
        'u_name': row[8],
        'b_date': row[9],
        # ...
    } for row in rows]
    
    return {"results": result}


# ============================================
# 상세 조회 (Read One)
# ////// 직원페이지 반품 상세
# ============================================
# TODO: ID로 단일 조회 API 구현
# - 존재하지 않으면 에러 응답
@app.get("/select_refund/{ref_seq}")
async def select_one(ref_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT ref_seq, pic_seq, s_seq, r.u_seq, ref_date, ref_re_seq, ref_re_content, 
                 b_seq, u_name, b_date, u_phone, u_id, p_name, sc_name, cc_name, b_quantity
        FROM refund as r
        inner join user as u
        on r.u_seq = u.u_seq
        inner join purchase_item as p
        on p.u_seq = u.u_seq
        inner join product as pr
        on p.p_seq = pr.p_seq
        inner join size_category as sc
        on sc.sc_seq = pr.sc_seq
        inner join color_category as cc
        on cc.cc_seq = pr.cc_seq
        WHERE ref_seq = %s
    """, (ref_seq))
    
    row = curs.fetchone()
    conn.close()
    
    if row is None:
        return {"result": "Error", "message": "refund not found"}
    
    # TODO: 결과 매핑
    result = {
        'ref_seq': row[0],
        'pic_seq': row[1],
        's_seq': row[2],
        'u_seq': row[3],
        'created_at': row[4],
        'ref_re_seq': row[5],
        'ref_re_content': row[6],
        'b_seq': row[7],
        'u_name': row[8],
        'b_date': row[9],
        'u_phone': row[10],
        'u_id': row[11],
        'p_name': row[12],
        'sc_name': row[13],
        'cc_name': row[14],
        'b_quantity': row[15],
        # ...
    }
    return {"result": result}


# ============================================
# 추가 (Create)
# ============================================
# TODO: 새 레코드 추가 API 구현
# - Form 데이터로 받기: 파라미터 = Form(...)
# - 성공 시 생성된 ID 반환
# - 에러 처리 필수
@app.post("/insert_[테이블명]")
async def insert_one(
    # TODO: Form 파라미터 정의
    # 예: columnName: str = Form(...)
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # TODO: SQL 작성
        sql = """
            INSERT INTO [테이블명] (column1, column2, ...) 
            VALUES (%s, %s, ...)
        """
        curs.execute(sql, (value1, value2, ...))
        
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
@app.post("/update_[테이블명]")
async def update_one(
    item_id: int = Form(...),
    # TODO: 수정할 Form 파라미터 정의
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # TODO: SQL 작성
        sql = """
            UPDATE [테이블명] 
            SET column1=%s, column2=%s, ... 
            WHERE id=%s
        """
        curs.execute(sql, (value1, value2, ..., item_id))
        
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
@app.delete("/delete_[테이블명]/{item_id}")
async def delete_one(item_id: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        sql = "DELETE FROM [테이블명] WHERE id=%s"
        curs.execute(sql, (item_id,))
        
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
    print(f"🚀 [테이블명] API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)

