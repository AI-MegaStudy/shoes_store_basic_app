"""
Customer API - Customer CRUD
개별 실행: python customer.py

작성자: 이광태
작성일: 2025-12-29

수정 이력:
|------------|--------|------------------|
  2025-12-29    이광태   최초 CRUD생성
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
class CustomerModel(BaseModel):
    id: Optional[int] = None
    cEmail: str
    cPhoneNumber: str
    cName: str
    cPassword: str
    cProfileImage: Optional[str] = None
   
# ============================================
# 전체 조회 (Read All)
# ============================================
@app.get("/select_users")
async def select_all():
  conn = connect_db()
  try:
    
    curs = conn.cursor()
    
    # id,cEmail,cPhoneNumber,cName,cPassword,cProfileImage
    curs.execute("""
        SELECT *
        FROM user 
        ORDER BY u_seq
    """)
    
    rows = curs.fetchall()

    results = [{
        "u_seq":row[0],
        "u_id":row[1],
        "u_password":row[2],
        "u_name":row[3],
        "u_phone":row[4],
        "u_image": base64.b64encode(row[5]),
        "u_address":row[6],
        "created_at":row[7],
        "u_quit_date":row[8]
        
    } for row in rows]
  
    return {"results": results}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 단일 조회 (Read One)
# ============================================
@app.get("/select_user/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT *
        FROM user
        WHERE u_seq = %s
    """, (item_id,))
    
    row = curs.fetchone()

    
    if row is None:
        return {"result": "Error", "message": "user not found"}
    
    # TODO: 결과 매핑
    result = {
        "u_seq":row[0],
        "u_id":row[1],
        "u_password":row[2],
        "u_name":row[3],
        "u_phone":row[4],
        "u_image": base64.b64encode(row[5]),
        "u_address":row[6],
        "created_at":row[7],
        "u_quit_date":row[8]
    }
    return {"result": result}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 추가 (Create)
# ============================================
@app.post("/insert_user")
async def insert_one(
  u_id:str = Form(...),
  u_password:str=Form(...),
  u_name:str=Form(...),
  u_phone:str=Form(...),
  u_image:Optional[UploadFile] = None,
  u_address:str=Form(...),
  created_at:Optional[str] = None,
  u_quit:Optional[str] = None
):
    if created_at is None:
      created_at = datetime.now()

    conn = connect_db()
    try:
       
        curs = conn.cursor()
        
        if u_image is not None:
          
          imageData = await u_image.read()
          sql = """
            INSERT INTO user (u_id,u_password,u_name,u_phone,u_image,u_address,created_at) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
          """
          curs.execute(sql, (u_id,u_password,u_name,u_phone,imageData,u_address,created_at))
        else:
          sql = """
            INSERT INTO user (u_id,u_password,u_name,u_phone,u_address,created_at) 
            VALUES (%s, %s, %s, %s, %s, %s)
          """
          curs.execute(sql, (u_id,u_password,u_name,u_phone,u_address,created_at))
        
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
@app.post("/update_user")
async def update_one(
    u_seq: int = Form(...),
    u_name:str=Form(...),
    u_phone:str=Form(...),
    u_image:Optional[UploadFile] = None,
    u_address:str=Form(...)
):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        
        # File 
        if u_image is not None:
           
          imageData = await u_image.read()
          sql = """
              UPDATE user
              SET u_name=%s, u_phone=%s,u_image=%s,u_address=%s
              WHERE u_seq=%s
          """
          curs.execute(sql, (u_name, u_phone,imageData,u_address,u_seq))
        else:
          sql = """
              UPDATE user
              SET u_name=%s, u_phone=%s,u_address=%s
              WHERE u_seq=%s
          """
          curs.execute(sql, (u_name, u_phone,u_address,u_seq))
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
@app.delete("/delete_user/{item_id}")
async def delete_one(item_id: int):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        
        sql = "DELETE FROM user WHERE u_seq=%s"
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
@app.get("/view_user_image/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT u_image
        FROM user
        WHERE u_seq = %s
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
# TODO: 이미지만 별도로 업데이트
# - UploadFile = File(...) 사용
@app.post("/update_uesr_image")
async def update_image(
    item_id: int = Form(...),
    file: UploadFile = File(...)
):
    try:
        image_data = await file.read()
        
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE user SET u_image=%s WHERE u_seq=%s"
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

