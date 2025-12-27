"""
================================================================================
Customer와 Employee 테이블에 프로필 이미지 BLOB 컬럼 추가 및 이미지 삽입 스크립트
================================================================================

[ 기능 ]
  - Customer 테이블에 cProfileImage (MEDIUMBLOB) 컬럼 추가
  - Employee 테이블에 eProfileImage (MEDIUMBLOB) 컬럼 추가
  - 같은 폴더의 더미 프로필 이미지를 모든 사용자에게 적용

[ 필요 파일 ]
  - 이 스크립트와 같은 폴더에 dummy-profile-pic.png 파일 필요

[ 사용 방법 ]
  1. 아래 DB_CONFIG를 대상 서버에 맞게 수정
  2. 터미널에서 실행:
     
     python add_profile_image_columns.py
     
  3. 또는 venv 환경에서:
     
     ./venv/bin/python database/add_profile_image_columns.py

[ 다른 서버에서 사용 시 ]
  1. database 폴더 전체를 복사
  2. 아래 DB_CONFIG 값만 수정:
     - host: 서버 주소
     - port: MySQL 포트 (기본 3306)
     - user: 사용자명
     - password: 비밀번호
     - database: 데이터베이스명
  3. 스크립트 실행

[ 주의 사항 ]
  - 컬럼이 이미 존재하면 건너뜀 (중복 실행 가능)
  - 모든 기존 사용자의 프로필 이미지를 덮어씀
  - MEDIUMBLOB: 최대 16MB 이미지 저장 가능

[ 작성일 ] 2025-12-27
================================================================================
"""

import os
import pymysql


# ============================================
# 데이터베이스 접속 정보 (⬇️ 다른 서버 사용 시 여기만 수정)
# ============================================
DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'port': 13306,
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'shoes_store_db',
    'charset': 'utf8mb4'
}

# 프로필 이미지 파일 (이 스크립트와 같은 폴더에 위치)
PROFILE_IMAGE_FILE = 'dummy-profile-pic.png'


def get_script_dir():
    """현재 스크립트가 위치한 디렉토리 경로 반환"""
    return os.path.dirname(os.path.abspath(__file__))


def load_profile_image():
    """같은 폴더의 프로필 이미지 파일을 바이너리로 읽기"""
    script_dir = get_script_dir()
    image_path = os.path.join(script_dir, PROFILE_IMAGE_FILE)
    
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"이미지 파일을 찾을 수 없습니다: {image_path}")
    
    with open(image_path, 'rb') as f:
        image_data = f.read()
    
    print(f"✅ 이미지 로드 완료: {PROFILE_IMAGE_FILE} ({len(image_data):,} bytes)")
    return image_data


def connect_db():
    """데이터베이스 연결"""
    print(f"📡 데이터베이스 연결 중... ({DB_CONFIG['host']}:{DB_CONFIG['port']})")
    conn = pymysql.connect(**DB_CONFIG)
    print("✅ 데이터베이스 연결 성공!")
    return conn


def add_profile_image_columns(cursor):
    """Customer와 Employee 테이블에 프로필 이미지 컬럼 추가"""
    
    # Customer 테이블에 cProfileImage 컬럼 추가
    print("\n[1/2] Customer 테이블에 cProfileImage 컬럼 추가 중...")
    try:
        cursor.execute("""
            ALTER TABLE Customer 
            ADD COLUMN cProfileImage MEDIUMBLOB NULL
        """)
        print("  ✅ Customer.cProfileImage 컬럼 추가 완료")
    except Exception as e:
        if "Duplicate column name" in str(e):
            print("  ⚠️ Customer.cProfileImage 컬럼이 이미 존재합니다")
        else:
            raise e
    
    # Employee 테이블에 eProfileImage 컬럼 추가
    print("[2/2] Employee 테이블에 eProfileImage 컬럼 추가 중...")
    try:
        cursor.execute("""
            ALTER TABLE Employee 
            ADD COLUMN eProfileImage MEDIUMBLOB NULL
        """)
        print("  ✅ Employee.eProfileImage 컬럼 추가 완료")
    except Exception as e:
        if "Duplicate column name" in str(e):
            print("  ⚠️ Employee.eProfileImage 컬럼이 이미 존재합니다")
        else:
            raise e


def update_all_profile_images(cursor, image_data):
    """모든 Customer와 Employee에게 프로필 이미지 적용"""
    
    # 모든 Customer에게 이미지 적용
    print("\n[Customer] 프로필 이미지 업데이트 중...")
    cursor.execute("UPDATE Customer SET cProfileImage = %s", (image_data,))
    customer_count = cursor.rowcount
    print(f"  ✅ {customer_count}명 업데이트 완료")
    
    # 모든 Employee에게 이미지 적용
    print("[Employee] 프로필 이미지 업데이트 중...")
    cursor.execute("UPDATE Employee SET eProfileImage = %s", (image_data,))
    employee_count = cursor.rowcount
    print(f"  ✅ {employee_count}명 업데이트 완료")
    
    return customer_count, employee_count


def show_results(cursor):
    """결과 확인"""
    print("\n" + "=" * 60)
    print("Customer 프로필 이미지 상태:")
    print("=" * 60)
    cursor.execute("""
        SELECT id, cName, 
               CASE WHEN cProfileImage IS NULL THEN '❌ 없음' 
                    ELSE CONCAT('✅ ', FORMAT(LENGTH(cProfileImage), 0), ' bytes') 
               END as profileStatus
        FROM Customer ORDER BY id
    """)
    for row in cursor.fetchall():
        print(f"  ID {row[0]:3} | {row[1]:15} | {row[2]}")
    
    print("\n" + "=" * 60)
    print("Employee 프로필 이미지 상태:")
    print("=" * 60)
    cursor.execute("""
        SELECT id, eName, 
               CASE WHEN eProfileImage IS NULL THEN '❌ 없음' 
                    ELSE CONCAT('✅ ', FORMAT(LENGTH(eProfileImage), 0), ' bytes') 
               END as profileStatus
        FROM Employee ORDER BY id
    """)
    for row in cursor.fetchall():
        print(f"  ID {row[0]:3} | {row[1]:15} | {row[2]}")


def main():
    """메인 실행 함수"""
    print("=" * 60)
    print("프로필 이미지 컬럼 추가 및 데이터 삽입 스크립트")
    print("=" * 60)
    
    # 1. 이미지 파일 로드
    print("\n📁 프로필 이미지 파일 로드 중...")
    image_data = load_profile_image()
    
    # 2. 데이터베이스 연결
    conn = connect_db()
    cursor = conn.cursor()
    
    try:
        # 3. 컬럼 추가
        print("\n📊 테이블 컬럼 추가...")
        add_profile_image_columns(cursor)
        
        # 4. 이미지 데이터 삽입
        print("\n🖼️ 프로필 이미지 적용...")
        customer_count, employee_count = update_all_profile_images(cursor, image_data)
        
        # 5. 커밋
        conn.commit()
        
        # 6. 결과 확인
        show_results(cursor)
        
        # 7. 완료 메시지
        print("\n" + "=" * 60)
        print("🎉 작업 완료!")
        print("=" * 60)
        print(f"  - Customer: {customer_count}명 프로필 이미지 적용")
        print(f"  - Employee: {employee_count}명 프로필 이미지 적용")
        print(f"  - 이미지 크기: {len(image_data):,} bytes")
        
    except Exception as e:
        print(f"\n❌ 에러 발생: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()
        print("\n📡 데이터베이스 연결 종료")


if __name__ == "__main__":
    main()
