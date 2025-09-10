-- ==========================================
-- Agentic SDK Server - 初始数据库结构
-- ==========================================
-- TimescaleDB 初始化脚本
-- 创建智能体会话存储所需的表结构

-- 启用 TimescaleDB 扩展
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- 创建 agentic_sessions 数据库（如果不存在）
-- 注意：在 Docker 容器中，数据库通过环境变量 POSTGRES_DB 创建

-- ==========================================
-- 会话数据表
-- ==========================================

-- 会话检查点表（存储 LangGraph 状态）
CREATE TABLE IF NOT EXISTS checkpoints (
    thread_id VARCHAR(255) NOT NULL,
    checkpoint_ns VARCHAR(255) NOT NULL DEFAULT '',
    checkpoint_id VARCHAR(255) NOT NULL,
    parent_checkpoint_id VARCHAR(255),
    type VARCHAR(50),
    checkpoint JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (thread_id, checkpoint_ns, checkpoint_id)
);

-- 创建时序表（TimescaleDB 特性）
SELECT create_hypertable('checkpoints', 'created_at', 
    if_not_exists => TRUE,
    chunk_time_interval => INTERVAL '1 day'
);

-- 会话检查点写入表（存储状态变更）
CREATE TABLE IF NOT EXISTS checkpoint_writes (
    thread_id VARCHAR(255) NOT NULL,
    checkpoint_ns VARCHAR(255) NOT NULL DEFAULT '',
    checkpoint_id VARCHAR(255) NOT NULL,
    task_id VARCHAR(255) NOT NULL,
    idx INTEGER NOT NULL,
    channel VARCHAR(255) NOT NULL,
    type VARCHAR(50),
    value JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (thread_id, checkpoint_ns, checkpoint_id, task_id, idx)
);

-- 创建时序表
SELECT create_hypertable('checkpoint_writes', 'created_at', 
    if_not_exists => TRUE,
    chunk_time_interval => INTERVAL '1 day'
);

-- ==========================================
-- 索引优化
-- ==========================================

-- checkpoints 表索引
CREATE INDEX IF NOT EXISTS idx_checkpoints_thread_id ON checkpoints(thread_id);
CREATE INDEX IF NOT EXISTS idx_checkpoints_created_at ON checkpoints(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_checkpoints_parent_id ON checkpoints(parent_checkpoint_id);
CREATE INDEX IF NOT EXISTS idx_checkpoints_type ON checkpoints(type);

-- 复合索引用于常见查询
CREATE INDEX IF NOT EXISTS idx_checkpoints_thread_ns ON checkpoints(thread_id, checkpoint_ns);
CREATE INDEX IF NOT EXISTS idx_checkpoints_thread_created ON checkpoints(thread_id, created_at DESC);

-- checkpoint_writes 表索引
CREATE INDEX IF NOT EXISTS idx_checkpoint_writes_thread_id ON checkpoint_writes(thread_id);
CREATE INDEX IF NOT EXISTS idx_checkpoint_writes_created_at ON checkpoint_writes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_checkpoint_writes_channel ON checkpoint_writes(channel);

-- 复合索引
CREATE INDEX IF NOT EXISTS idx_checkpoint_writes_thread_checkpoint ON checkpoint_writes(thread_id, checkpoint_id);
CREATE INDEX IF NOT EXISTS idx_checkpoint_writes_task ON checkpoint_writes(thread_id, task_id);

-- ==========================================
-- 会话统计视图
-- ==========================================

-- 创建会话统计视图
CREATE OR REPLACE VIEW session_stats AS
SELECT 
    thread_id,
    COUNT(*) as checkpoint_count,
    MIN(created_at) as first_activity,
    MAX(created_at) as last_activity,
    MAX(created_at) - MIN(created_at) as session_duration,
    array_agg(DISTINCT type) as checkpoint_types
FROM checkpoints 
GROUP BY thread_id;

-- ==========================================
-- 数据保留策略
-- ==========================================

-- 设置数据保留策略：保留 30 天的数据
SELECT add_retention_policy('checkpoints', INTERVAL '30 days', if_not_exists => true);
SELECT add_retention_policy('checkpoint_writes', INTERVAL '30 days', if_not_exists => true);

-- ==========================================
-- 压缩策略（可选）
-- ==========================================

-- 启用压缩以节省存储空间
-- 对 7 天以前的数据进行压缩
SELECT add_compression_policy('checkpoints', INTERVAL '7 days', if_not_exists => true);
SELECT add_compression_policy('checkpoint_writes', INTERVAL '7 days', if_not_exists => true);

-- ==========================================
-- 用户权限设置
-- ==========================================

-- 为应用创建专用用户（如果需要）
-- CREATE USER agentic_app WITH PASSWORD 'secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON checkpoints TO agentic_app;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON checkpoint_writes TO agentic_app;
-- GRANT USAGE ON SCHEMA public TO agentic_app;

-- ==========================================
-- 初始化完成标记
-- ==========================================

-- 创建版本表来跟踪数据库架构版本
CREATE TABLE IF NOT EXISTS schema_version (
    version INTEGER PRIMARY KEY,
    description TEXT,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 插入初始版本记录
INSERT INTO schema_version (version, description) 
VALUES (1, 'Initial database schema for Agentic SDK Server')
ON CONFLICT (version) DO NOTHING;

-- ==========================================
-- 统计信息和分析
-- ==========================================

-- 更新表统计信息
ANALYZE checkpoints;
ANALYZE checkpoint_writes;

-- 输出初始化完成信息
DO $$ 
BEGIN 
    RAISE NOTICE 'Agentic SDK Server database schema initialized successfully!';
    RAISE NOTICE 'Tables created: checkpoints, checkpoint_writes';
    RAISE NOTICE 'Hypertables enabled for time-series data';
    RAISE NOTICE 'Retention policy: 30 days';
    RAISE NOTICE 'Compression policy: 7 days';
END $$;