"""
데이터베이스 연결 설정
예제 코드 스타일로 간단하게 구현
"""

import pymysql


# 데이터베이스 설정 (나중에 환경변수로 변경)
# DB_CONFIG = {
#     'host': '127.0.0.1',
#     'user': 'root',
#     'password': 'qwer1234',  # 실제 사용 시 환경변수로 변경
#     'database': 'shoes_store_db',  # 데이터베이스 이름 (init.sql에서 생성한 이름)
#     'charset': 'utf8mb4'
# }

DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',  # 실제 사용 시 환경변수로 변경
    'database': 'shoes_store_db',  # 데이터베이스 이름 (init.sql에서 생성한 이름)
    'charset': 'utf8mb4',
    'port': 13306
}


def connect_db():
    """
    데이터베이스 연결
    
    Returns:
        pymysql.Connection: 데이터베이스 연결 객체
    """
    conn = pymysql.connect(**DB_CONFIG)
    return conn

