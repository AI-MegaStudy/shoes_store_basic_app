"""
Employee API - Employee CRUD
개별 실행: python employee.py

작성자: 이광태
작성일: 2025-12-29

수정 이력:

|------------|--------|------------------|
2025-12-29    이광태    최초 CRUD생성. 
"""

from fastapi import FastAPI, Form, UploadFile, File, Response
from pydantic import BaseModel
from typing import Optional
from database.connection import connect_db
import base64
from datetime import datetime


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
class EmployeeModel(BaseModel):
    id: Optional[int] = None
    eEmail: str
    ePhoneNumber: str
    eName: str
    ePassword: str
    eRole: str
    eProfileImage: Optional[str] = None
   
# ============================================
# 전체 조회 (Read All)
# ============================================
@app.get("/select_staffs")
async def select_all():
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # id,cEmail,cPhoneNumber,cName,cPassword,cProfileImage
    curs.execute("""
        SELECT *
        FROM staff 
        ORDER BY s_seq
    """)
    
    rows = curs.fetchall()
    

    results = [{
        "s_seq":row[0],
        "s_id":row[1],
        "br_seq":row[2],
        "s_image":base64.b64encode(row[4]),
        "s_rank":row[5],
        "s_phone":row[6],
        "s_name":row[7],
        "s_superseq":row[8],
        "created_at":row[9],
        "s_quit_date":row[10],
        
    } for row in rows]
  
    return {"results": results}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 단일 조회 (Read One)
# ============================================
@app.get("/select_staff/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
        SELECT *
        FROM staff
        WHERE s_seq = %s
    """, (item_id,))
    
    row = curs.fetchone()
    
    
    if row is None:
        return {"result": "Error", "message": "staff not found"}
    
    # TODO: 결과 매핑
    result = {
        "s_seq":row[0],
        "s_id":row[1],
        "br_seq":row[2],
        "s_image":base64.b64encode(row[4]),
        "s_rank":row[5],
        "s_phone":row[6],
        "s_name":row[7],
        "s_superseq":row[8],
        "created_at":row[9],
        "s_quit_date":row[10],
    }
    return {"result": result}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 추가 (Create)
# ============================================
@app.post("/insert_staff")
async def insert_one(
  s_id:str = Form(...),
  br_seq:int=Form(...),
  s_password:str=Form(...),
  s_image:Optional[UploadFile] = None,
  s_rank:str=Form(...),
  s_phone:str=Form(...),
  s_name:str=Form(...),
  s_superseq:int=Form(...),
  created_at:Optional[str] = None 
 
):  
    if created_at is None:
       created_at = datetime.now()
    conn = connect_db()
    try:
        curs = conn.cursor()
        if s_image is not None:
          imageData = await s_image.read()
          sql = """
            INSERT INTO staff (s_id,br_seq,s_password,s_image,s_rank,s_phone,s_name,s_superseq,created_at) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
          """
          curs.execute(sql, (s_id,br_seq,s_password,imageData,s_rank,s_phone,s_name,s_superseq,created_at))
        else:
          sql = """
            INSERT INTO staff (s_id,br_seq,s_password,s_rank,s_phone,s_name,s_superseq,created_at) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
          """
          curs.execute(sql, (s_id,br_seq,s_password,s_rank,s_phone,s_name,s_superseq,created_at))
        
        conn.commit()
        inserted_id = curs.lastrowid
       
        
        return {"result": "OK", "id": inserted_id}
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
      conn.close()

# ============================================
# 수정 (Update)
# ============================================
# TODO: 레코드 수정 API 구현
# - 이미지 BLOB이 있는 경우: 이미지 제외/포함 두 가지 API 구현 권장
@app.post("/update_staff")
async def update_one(
  s_seq:Optional[int] = None, 
  s_id:str = Form(...),
  br_seq:int=Form(...),
  s_password:str=Form(...),
  s_image:Optional[UploadFile] = None,
  s_rank:str=Form(...),
  s_phone:str=Form(...),
  s_name:str=Form(...),
  s_superseq:int=Form(...)
):
    conn = connect_db()
    try:
        curs = conn.cursor()
        # File 
        if s_image is not None:
           
          imageData = await s_image.read()
          sql = """
              UPDATE staff
              SET br_seq=%s, s_image=%s, s_rank=%s,s_phone=%s,s_name=%s,s_superseq=%s
              WHERE s_seq=%s
          """
          curs.execute(sql, (br_seq, imageData, s_rank,s_phone,s_name,s_superseq,s_seq))
        else:
          sql = """
              UPDATE staff
              SET br_seq=%s, s_rank=%s,s_phone=%s,s_name=%s,s_superseq=%s
              WHERE s_seq=%s
          """
          curs.execute(sql, (br_seq, s_rank,s_phone,s_name,s_superseq,s_seq))
        conn.commit()
        
        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
       conn.close()

# ============================================
# 삭제 (Delete)
# ============================================
# TODO: 레코드 삭제 API 구현
# - FK 참조 시 삭제 실패할 수 있음 (에러 처리)
@app.delete("/delete_staff/{item_id}")
async def delete_one(item_id: int):
    conn = connect_db()
    try:
        curs = conn.cursor()
        sql = "DELETE FROM staff WHERE s_seq=%s"
        curs.execute(sql, (item_id,))
        conn.commit()

        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
       conn.close()






# ============================================
# [선택] 이미지 조회 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
# @app.get("/select_employee/{item_id}/profile_image")
@app.get("/view_staff_image/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
        SELECT s_image
        FROM staff
        WHERE s_seq = %s
    """, (item_id,))
    
    row = curs.fetchone()
    if row is None:
      return {"result": "Error", "message": "Customer not found"}
    if row[0] is None:
      return {"result": "Error", "message": "No profile image"}
    # Response 객체로 바이너리 직접 반환
    return Response(
      content=row[0],
      media_type="image/jpeg",
      headers={"Cache-Control": "no-cache, no-store, must-revalidate"}
    )
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
    conn.close()




# ============================================
# [선택] 이미지 업데이트 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
#TODO: 이미지만 별도로 업데이트
# - UploadFile = File(...) 사용
@app.post("/update_staff_image")
async def update_image(
    item_id: int = Form(...),
    file: UploadFile = File(...)
):
    conn = connect_db()
    try:
        image_data = await file.read()
        
        
        curs = conn.cursor()
        sql = "UPDATE staff SET s_image=%s WHERE s_seq=%s"
        curs.execute(sql, (image_data, item_id))
        conn.commit()
       
        
        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
      conn.close()


# ============================================
# 개별 실행
# ============================================
if __name__ == "__main__":
    import uvicorn
    print(f"🚀 [테이블명] API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)

