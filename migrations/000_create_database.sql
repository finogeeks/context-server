-- ==========================================
-- Agentic SDK Server - 数据库创建脚本
-- ==========================================
-- 确保 agentic_db 数据库存在
-- 此脚本在所有其他迁移脚本之前执行

-- 输出当前状态信息
DO $$ 
BEGIN 
    RAISE NOTICE '=== Database Creation Check ===';
    RAISE NOTICE 'Current database: %', current_database();
    RAISE NOTICE 'Current user: %', current_user;
    RAISE NOTICE 'PostgreSQL version: %', version();
END $$;

-- 创建 agentic_db 数据库（如果不存在）
-- 注意：这个脚本可能在 template1 或 postgres 数据库中执行
SELECT 'CREATE DATABASE agentic_db'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'agentic_db'
)\gexec

-- 验证数据库是否已创建
DO $$ 
BEGIN 
    IF EXISTS (SELECT FROM pg_database WHERE datname = 'agentic_db') THEN
        RAISE NOTICE 'Database "agentic_db" confirmed to exist';
    ELSE
        RAISE EXCEPTION 'Failed to create or find database "agentic_db"';
    END IF;
END $$;

-- 输出完成信息
DO $$ 
BEGIN 
    RAISE NOTICE 'Database creation check completed successfully';
    RAISE NOTICE '=== End Database Creation Check ===';
END $$;