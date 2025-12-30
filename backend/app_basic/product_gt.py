"""
Product API - Product CRUD
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
import datetime

app = FastAPI()
ipAddress = "127.0.0.1"
port = 8000


# ============================================
# 모델 정의
# ============================================
class ProductModel(BaseModel):
    p_seq: Optional[int] = None
    kc_seq: int
    cc_seq: int
    sc_seq: int
    gc_seq: int
    m_seq: int
    p_name: str
    p_price: int
    p_stock: int
    p_image: Optional[str] = None
    p_color: str
    p_size: str
    p_gender: str
    p_maker: str
    
   
# ============================================
# 전체 조회 (Read All)
# ============================================
@app.get("/select_products")
async def select_all():
  conn = connect_db()
  try:
    
    curs = conn.cursor()
    #0 p_seq: Optional[int] = None
    #1 kc_seq: int
    #2 cc_seq: int
    #3 sc_seq: int
    #4 gc_seq: int
    #5 m_seq: int
    #6 p_name: str
    #7 p_price: int
    #8 p_stock: int
    #9 p_image: Optional[str] = None
    #10 p_color: str
    #11 p_size: str
    #12 p_gender: str
     

    curs.execute("""
        select p.*,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
        from product p 
        inner join color_category cc on p.cc_seq=cc.cc_seq
        inner join gender_category gc on p.gc_seq=gc.gc_seq
        inner join size_category sc on p.sc_seq=sc.sc_seq
        inner join maker ma on p.m_seq=ma.m_seq
        ORDER BY p.p_seq
    """)
    
    rows = curs.fetchall()

    results = [{
        "p_seq": row[0],
        "kc_seq": row[1],
        "cc_seq": row[2],
        "sc_seq": row[3],
        "gc_seq": row[4],
        "m_seq": row[5],
        "p_name": row[6],
        "p_price": row[7],
        "p_stock": row[8],
        "p_image": row[9],
        "p_description" : row[10],
        "p_date": str(row[11]),
        "p_color": row[12],
        "p_size": row[13],
        "p_gender": row[14],
        "p_maker": row[15],
    } for row in rows]
  
    return {"results": results}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()


# ============================================
# 전체 조회 (Read All)
# ============================================
# Todo: GT - search keywords validation (inject handle)   
@app.get("/select_search")
async def select_search(
  maker: Optional[str]=None,
  kwds: Optional[str]=None,
  color: Optional[str]=None,
  kc_name: Optional[str]=None
):
  
  #### 쿼리 조건문 만들기
  data = []
  qry_condition = 'where 1=1 and '
  if maker is not None:
    qry_condition += 'ma.m_name=%s and '
    data.append(maker)
  kwds_condition = ''
  if kwds is not None:
    for kwd in kwds.split(' '):
      kwds_condition += 'p.p_name like %s or '
      data.append(f"%{kwd}%")
  if kwds_condition != '':
    qry_condition += f'({kwds_condition[0:len(kwds_condition)-3]}) and '
  if color is not None:
    qry_condition += 'cc.cc_name=%s and '
    data.append(color)
  qry_condition = qry_condition[0:len(qry_condition)-4]
  #### END OF 쿼리 조건문 만들기

  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
          select p.*,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
          from product p 
          inner join color_category cc on p.cc_seq=cc.cc_seq
          inner join gender_category gc on p.gc_seq=gc.gc_seq
          inner join size_category sc on p.sc_seq=sc.sc_seq
          inner join maker ma on p.m_seq=ma.m_seq 
          """ + qry_condition,data
    )
    rows = curs.fetchall()
    results = [{
        "p_seq": row[0],
        "kc_seq": row[1],
        "cc_seq": row[2],
        "sc_seq": row[3],
        "gc_seq": row[4],
        "m_seq": row[5],
        "p_name": row[6],
        "p_price": row[7],
        "p_stock": row[8],
        "p_image": row[9],
        "p_description" : row[10],
        "p_date": str(row[11]),
        "p_color": row[12],
        "p_size": row[13],
        "p_gender": row[14],
        "p_maker": row[15],
    } for row in rows]
  
    return {"results": results}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 단일 조회 (Read One)
# ============================================
@app.get("/select_product/{item_id}")
async def select_one(item_id: int):
  conn = connect_db()
  try:
    curs = conn.cursor()
    
    # TODO: SQL 작성
    curs.execute("""
       select p.*,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name as p_maker
        from product p 
        inner join color_category cc on p.cc_seq=cc.cc_seq
        inner join gender_category gc on p.gc_seq=gc.gc_seq
        inner join size_category sc on p.sc_seq=sc.sc_seq
        inner join maker ma on p.m_seq=ma.m_seq
        WHERE p.p_seq = %s
    """, (item_id,))
    
    row = curs.fetchone()

    
    if row is None:
        return {"result": "Error", "message": "[테이블명] not found"}
    
    # TODO: 결과 매핑
    result = {
        "p_seq": row[0],
        "kc_seq": row[1],
        "cc_seq": row[2],
        "sc_seq": row[3],
        "gc_seq": row[4],
        "m_seq": row[5],
        "p_name": row[6],
        "p_price": row[7],
        "p_stock": row[8],
        "p_image": row[9], #base64.b64encode(row[9]),
        "p_description" : row[10],
        "p_date": row[11],
        "p_color": row[12],
        "p_size": row[13],
        "p_gender": row[14],
        "p_maker": row[15],
    }
    return {"result": result}
  except Exception as error:
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()

# ============================================
# 추가 (Create)
# ============================================
@app.post("/insert_product")
async def insert_one(
  p_seq: Optional[int] = None,
  kc_seq: int = Form(...),
  cc_seq: int = Form(...),
  sc_seq: int = Form(...),
  gc_seq: int = Form(...),
  m_seq: int = Form(...),
  p_name: str = Form(...),
  p_price: int = Form(...),
  p_stock: int = Form(...),
  # file: Optional[UploadFile] = None,
  p_image: str = Form(...),
  p_description: str = Form(...),
  p_date : Optional[str] = None
):
    conn = connect_db()
    try:
        if p_date is None:
           p_date = str(datetime.datetime.now())
        curs = conn.cursor()
        sql = """
            INSERT INTO product (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_image,p_description,p_date) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
          """
        curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_image,p_description,p_date))
        # if file is not None:
          
        #   imageData = await file.read()
        #   sql = """
        #     INSERT INTO product (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_image,p_description,p_date) 
        #     VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        #   """
        #   curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,file,p_description,p_date))
        # else:
        #   sql = """
        #     INSERT INTO Customer (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_description,p_date) 
        #     VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        #   """
        #   curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_description,p_date))
        
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
@app.post("/update_product")
async def update_one(
  item_id: int = Form(...),
  kc_seq: int = Form(...),
  cc_seq: int = Form(...),
  sc_seq: int = Form(...),
  gc_seq: int = Form(...),
  m_seq: int = Form(...),
  p_name: str = Form(...),
  p_price: int = Form(...),
  p_stock: int = Form(...),
  # file: Optional[UploadFile] = None,
  p_image:str = Form(...),
  p_description: str = Form(...)
):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        sql = """
              UPDATE product
              SET kc_seq = %s,
              cc_seq = %s,
              sc_seq = %s,
              gc_seq = %s,
              m_seq = %s,
              p_name = %s,
              p_price = %s,
              p_stock = %s,
              p_image = %s,
              p_description = %s
              WHERE p_seq=%s
          """
        curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,p_image, p_description, item_id))
        # # File 
        # if file is not None:
           
        #   imageData = await file.read()
        #   sql = """
        #       UPDATE product
        #       SET kc_seq = %s,
        #       cc_seq = %s,
        #       sc_seq = %s,
        #       gc_seq = %s,
        #       m_seq = %s,
        #       p_name = %s,
        #       p_price = %s,
        #       p_stock = %s,
        #       p_image = %s,
        #       p_description = %s,
        #       WHERE p_seq=%s
        #   """
        #   curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock,file, p_description, item_id))
        # else:
        #   sql = """
        #       UPDATE product
        #       SET kc_seq = %s,
        #       cc_seq = %s,
        #       sc_seq = %s,
        #       gc_seq = %s,
        #       m_seq = %s,
        #       p_name = %s,
        #       p_price = %s,
        #       p_stock = %s,
        #       p_description = %s,
        #       WHERE p_seq=%s
        #   """
        #   curs.execute(sql, (kc_seq,cc_seq,sc_seq,gc_seq,m_seq,p_name,p_price,p_stock, p_description, item_id))
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
@app.delete("/delete_product/{item_id}")
async def delete_one(item_id: int):
    conn = connect_db()
    try:
        
        curs = conn.cursor()
        
        sql = "DELETE FROM product WHERE p_seq=%s"
        curs.execute(sql, (item_id,))
        
        conn.commit()
        
        
        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
       conn.close()







# # ============================================
# # [선택] 이미지 조회 (이미지 BLOB 컬럼이 있는 경우)
# # ============================================
# @app.get("/view_product_image/{item_id}")
# async def select_one(item_id: int):
#   conn = connect_db()
#   try:
#     curs = conn.cursor()
    
#     # TODO: SQL 작성
#     curs.execute("""
#         SELECT p_image
#         FROM product
#         WHERE id = %s
#     """, (item_id,))
    
#     row = curs.fetchone()
#     if row is None:
#       return {"result": "Error", "message": "Product is not found"}
#     if row[0] is None:
#       return {"result": "Error", "message": "No product image"}
#     # Response 객체로 바이너리 직접 반환
#     return Response(
#       content=row[0],
#       media_type="image/jpeg",
#       headers={"Cache-Control": "no-cache, no-store, must-revalidate"}
#     )
#   except Exception as error:
#     return {"result": "Error", "errorMsg": str(error)}
#   finally:
#      conn.close()



# # ============================================
# # [선택] 이미지 업데이트 (이미지 BLOB 컬럼이 있는 경우)
# # ============================================
# # TODO: 이미지만 별도로 업데이트
# # - UploadFile = File(...) 사용
# @app.post("/update_product_image")
# async def update_image(
#     item_id: int = Form(...),
#     file: UploadFile = File(...)
# ):
#     try:
#         image_data = await file.read()
        
#         conn = connect_db()
#         curs = conn.cursor()
#         sql = "UPDATE product SET p_image=%s WHERE id=%s"
#         curs.execute(sql, (image_data, item_id))
#         conn.commit()
        
        
#         return {"result": "OK"}
#     except Exception as e:
#         conn.rollback()
#         return {"result": "Error", "errorMsg": str(e)}
#     finally:
#        conn.close()


# ============================================
# 개별 실행
# ============================================
if __name__ == "__main__":
    import uvicorn
    print(f"🚀 [테이블명] API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)

