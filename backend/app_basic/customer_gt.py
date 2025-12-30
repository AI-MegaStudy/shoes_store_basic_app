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
@app.get("/select_customers")
async def select_all():
  conn = connect_db()
  try:
    
    curs = conn.cursor()
    
    # id,cEmail,cPhoneNumber,cName,cPassword,cProfileImage
    curs.execute("""
        SELECT *
        FROM Customer 
        ORDER BY id
    """)
    
    rows = curs.fetchall()

    results = [{
        "id":row[0],
        "cEmail":row[1],
        "cPhoneNumber":row[2],
        "cName":row[3],
        "cPassword":row[4],
        "cProfileImage": base64.b64encode(row[5])
    } for row in rows]
  
    return {"results": results}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 단일 조회 (Read One)
# ============================================
@app.get("/select_customer/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT *
        FROM Customer
        WHERE id = %s
    """, (item_id,))
    
    row = curs.fetchone()

    
    if row is None:
        return {"result": "Error", "message": "[테이블명] not found"}
    
    # TODO: 결과 매핑
    result = {
        "id":row[0],
        "cEmail":row[1],
        "cPhoneNumber":row[2],
        "cName":row[3],
        "cPassword":row[4],
        "cProfileImage":base64.b64encode(row[5])
    }
    return {"result": result}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 추가 (Create)
# ============================================
@app.post("/insert_customer")
async def insert_one(
  cEmail:str = Form(...),
  cPhoneNumber:str=Form(...),
  cName:str=Form(...),
  cPassword:str=Form(...),
  file:Optional[UploadFile] = None
):
    conn = connect_db()
    try:
       
        curs = conn.cursor()

        if file is not None:
          
          imageData = await file.read()
          sql = """
            INSERT INTO Customer (cEmail,cPhoneNumber,cName,cPassword,cProfileImage) 
            VALUES (%s, %s, %s, %s, %s)
          """
          curs.execute(sql, (cEmail, cPhoneNumber,cName,cPassword,imageData))
        else:
          sql = """
            INSERT INTO Customer (cEmail,cPhoneNumber,cName,cPassword) 
            VALUES (%s, %s, %s, %s)
          """
          curs.execute(sql, (cEmail, cPhoneNumber,cName,cPassword))
        
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
@app.post("/update_customer")
async def update_one(
    item_id: int = Form(...),
    cEmail:str = Form(...),
    cPhoneNumber:str=Form(...),
    cName:str=Form(...),
    cPassword:str=Form(...),
    file:Optional[UploadFile] = None
):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        
        # File 
        if file is not None:
           
          imageData = await file.read()
          sql = """
              UPDATE Customer
              SET cEmail=%s, cPhoneNumber=%s,cName=%s,cPassword=%s,cProfileImage=%s
              WHERE id=%s
          """
          curs.execute(sql, (cEmail, cPhoneNumber, cName, cPassword, imageData, item_id))
        else:
          sql = """
              UPDATE Customer
              SET cEmail=%s, cPhoneNumber=%s,cName=%s,cPassword=%s
              WHERE id=%s
          """
          curs.execute(sql, (cEmail, cPhoneNumber, cName, cPassword, item_id))
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
@app.delete("/delete_customer/{item_id}")
async def delete_one(item_id: int):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        
        sql = "DELETE FROM Customer WHERE id=%s"
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
@app.get("/view_customer_image/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
        SELECT cProfileImage
        FROM Customer
        WHERE id = %s
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
@app.post("/update_customer_image")
async def update_image(
    item_id: int = Form(...),
    file: UploadFile = File(...)
):
    try:
        image_data = await file.read()
        
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE Customer SET cProfileImage=%s WHERE id=%s"
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

