-- ARgument WebAR Service Database Schema
-- PostgreSQL 15+
-- Created: 2024

-- ==================== EXTENSIONS ====================

-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ==================== ENUMS ====================

CREATE TYPE user_role AS ENUM ('user', 'admin');
CREATE TYPE project_status AS ENUM ('active', 'archived', 'deleted');
CREATE TYPE video_status AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE tracking_quality AS ENUM ('excellent', 'good', 'fair', 'poor');
CREATE TYPE event_type AS ENUM (
    'view_started',
    'marker_detected',
    'video_started',
    'video_paused',
    'video_completed',
    'video_replayed',
    'session_ended'
);

-- ==================== TABLES ====================

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    role user_role DEFAULT 'user' NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    email_verified BOOLEAN DEFAULT false NOT NULL,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- User quotas table
CREATE TABLE user_quotas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    max_projects INTEGER DEFAULT 5 NOT NULL,
    max_storage_bytes BIGINT DEFAULT 524288000 NOT NULL, -- 500MB
    max_video_length_seconds INTEGER DEFAULT 120 NOT NULL, -- 2 minutes
    max_views_per_month INTEGER DEFAULT 1000 NOT NULL,
    current_storage_bytes BIGINT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Refresh tokens table
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    tags TEXT[], -- Array of tags
    is_public BOOLEAN DEFAULT true NOT NULL,
    status project_status DEFAULT 'active' NOT NULL,
    total_views INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Images table
CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    file_path TEXT NOT NULL,
    thumbnail_path TEXT,
    original_size BIGINT NOT NULL, -- Bytes
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    format VARCHAR(10) NOT NULL, -- jpeg, png
    mime_type VARCHAR(50) NOT NULL,
    tracking_score DECIMAL(5,2), -- 0-100 score for AR tracking quality
    metadata JSONB, -- EXIF and other metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Videos table
CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    file_path TEXT NOT NULL,
    poster_path TEXT, -- Thumbnail/preview image
    original_size BIGINT NOT NULL, -- Bytes
    processed_size BIGINT, -- Size after transcoding
    duration DECIMAL(10,2), -- Duration in seconds
    width INTEGER,
    height INTEGER,
    format VARCHAR(10) NOT NULL, -- mp4, webm, mov
    codec VARCHAR(50),
    bitrate INTEGER,
    fps DECIMAL(5,2),
    status video_status DEFAULT 'pending' NOT NULL,
    autoplay BOOLEAN DEFAULT true NOT NULL,
    loop BOOLEAN DEFAULT false NOT NULL,
    processing_error TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE
);

-- AR Markers table
CREATE TABLE markers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    image_id UUID NOT NULL REFERENCES images(id) ON DELETE CASCADE,
    video_id UUID REFERENCES videos(id) ON DELETE SET NULL,
    marker_data TEXT NOT NULL, -- Serialized marker features (JSON or binary)
    marker_file_path TEXT, -- Path to .fset or .iset file for AR.js
    tracking_quality tracking_quality,
    settings JSONB NOT NULL DEFAULT '{}', -- scale, offset, rotation, opacity
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- WebAR Links table
CREATE TABLE links (
    id VARCHAR(50) PRIMARY KEY, -- Short unique slug
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    marker_id UUID NOT NULL REFERENCES markers(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    password_hash VARCHAR(255), -- Optional password protection
    expires_at TIMESTAMP WITH TIME ZONE,
    max_views INTEGER, -- Limit number of views
    current_views INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- AR Sessions table
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    link_id VARCHAR(50) NOT NULL REFERENCES links(id) ON DELETE CASCADE,
    fingerprint VARCHAR(255), -- Browser fingerprint for unique visitor tracking
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(50), -- mobile, desktop, tablet
    browser VARCHAR(100),
    os VARCHAR(100),
    country VARCHAR(2), -- ISO country code
    city VARCHAR(255),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- Duration in seconds
    marker_detected_at TIMESTAMP WITH TIME ZONE,
    video_started_at TIMESTAMP WITH TIME ZONE,
    video_completed BOOLEAN DEFAULT false
);

-- Analytics Events table
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    event_type event_type NOT NULL,
    metadata JSONB, -- Additional event data
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Analytics Aggregations table (for faster queries)
CREATE TABLE analytics_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_views INTEGER DEFAULT 0 NOT NULL,
    unique_viewers INTEGER DEFAULT 0 NOT NULL,
    total_duration INTEGER DEFAULT 0 NOT NULL, -- Total watch time in seconds
    completed_views INTEGER DEFAULT 0 NOT NULL,
    avg_watch_time DECIMAL(10,2),
    completion_rate DECIMAL(5,2),
    devices JSONB, -- Device breakdown
    browsers JSONB, -- Browser breakdown
    countries JSONB, -- Country breakdown
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE(project_id, date)
);

-- Audit Log table (for admin actions)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ==================== INDEXES ====================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Projects
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX idx_projects_total_views ON projects(total_views DESC);
CREATE INDEX idx_projects_name_trgm ON projects USING gin(name gin_trgm_ops);
CREATE INDEX idx_projects_tags ON projects USING gin(tags);

-- Images
CREATE INDEX idx_images_project_id ON images(project_id);
CREATE INDEX idx_images_created_at ON images(created_at);

-- Videos
CREATE INDEX idx_videos_project_id ON videos(project_id);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_videos_created_at ON videos(created_at);

-- Markers
CREATE INDEX idx_markers_image_id ON markers(image_id);
CREATE INDEX idx_markers_video_id ON markers(video_id);

-- Links
CREATE INDEX idx_links_project_id ON links(project_id);
CREATE INDEX idx_links_marker_id ON links(marker_id);
CREATE INDEX idx_links_is_active ON links(is_active);
CREATE INDEX idx_links_current_views ON links(current_views);

-- Sessions
CREATE INDEX idx_sessions_link_id ON sessions(link_id);
CREATE INDEX idx_sessions_started_at ON sessions(started_at);
CREATE INDEX idx_sessions_fingerprint ON sessions(fingerprint);
CREATE INDEX idx_sessions_ip_address ON sessions(ip_address);

-- Analytics Events
CREATE INDEX idx_analytics_events_session_id ON analytics_events(session_id);
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_timestamp ON analytics_events(timestamp);

-- Analytics Daily
CREATE INDEX idx_analytics_daily_project_id ON analytics_daily(project_id);
CREATE INDEX idx_analytics_daily_date ON analytics_daily(date DESC);
CREATE UNIQUE INDEX idx_analytics_daily_project_date ON analytics_daily(project_id, date);

-- Audit Logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Refresh Tokens
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- ==================== FUNCTIONS ====================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_quotas_updated_at BEFORE UPDATE ON user_quotas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_images_updated_at BEFORE UPDATE ON images
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_videos_updated_at BEFORE UPDATE ON videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_markers_updated_at BEFORE UPDATE ON markers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_links_updated_at BEFORE UPDATE ON links
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analytics_daily_updated_at BEFORE UPDATE ON analytics_daily
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create user quota on user creation
CREATE OR REPLACE FUNCTION create_user_quota()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_quotas (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_user_quota_trigger AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_user_quota();

-- Function to increment link views
CREATE OR REPLACE FUNCTION increment_link_views(link_id_param VARCHAR(50))
RETURNS VOID AS $$
BEGIN
    UPDATE links
    SET current_views = current_views + 1
    WHERE id = link_id_param;
    
    UPDATE projects
    SET total_views = total_views + 1
    WHERE id = (SELECT project_id FROM links WHERE id = link_id_param);
END;
$$ LANGUAGE plpgsql;

-- Function to check user quota
CREATE OR REPLACE FUNCTION check_user_quota_projects(user_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_count INTEGER;
    max_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO current_count
    FROM projects
    WHERE user_id = user_id_param AND status = 'active';
    
    SELECT max_projects INTO max_count
    FROM user_quotas
    WHERE user_id = user_id_param;
    
    RETURN current_count < max_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update user storage usage
CREATE OR REPLACE FUNCTION update_user_storage(user_id_param UUID)
RETURNS VOID AS $$
DECLARE
    total_storage BIGINT;
BEGIN
    SELECT COALESCE(SUM(i.original_size), 0) + COALESCE(SUM(v.original_size), 0)
    INTO total_storage
    FROM projects p
    LEFT JOIN images i ON i.project_id = p.id
    LEFT JOIN videos v ON v.project_id = p.id
    WHERE p.user_id = user_id_param;
    
    UPDATE user_quotas
    SET current_storage_bytes = total_storage
    WHERE user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to aggregate daily analytics
CREATE OR REPLACE FUNCTION aggregate_daily_analytics(
    project_id_param UUID,
    date_param DATE
)
RETURNS VOID AS $$
DECLARE
    total_views_count INTEGER;
    unique_viewers_count INTEGER;
    total_duration_sum INTEGER;
    completed_views_count INTEGER;
    avg_watch_time_calc DECIMAL(10,2);
    completion_rate_calc DECIMAL(5,2);
    devices_data JSONB;
    browsers_data JSONB;
    countries_data JSONB;
BEGIN
    -- Get sessions for the project and date
    WITH project_sessions AS (
        SELECT s.*
        FROM sessions s
        JOIN links l ON s.link_id = l.id
        WHERE l.project_id = project_id_param
        AND DATE(s.started_at) = date_param
    )
    SELECT
        COUNT(*),
        COUNT(DISTINCT fingerprint),
        COALESCE(SUM(duration), 0),
        COUNT(*) FILTER (WHERE video_completed = true),
        AVG(duration),
        (COUNT(*) FILTER (WHERE video_completed = true)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
    INTO
        total_views_count,
        unique_viewers_count,
        total_duration_sum,
        completed_views_count,
        avg_watch_time_calc,
        completion_rate_calc
    FROM project_sessions;
    
    -- Aggregate device types
    SELECT jsonb_object_agg(device_type, count)
    INTO devices_data
    FROM (
        SELECT device_type, COUNT(*) as count
        FROM sessions s
        JOIN links l ON s.link_id = l.id
        WHERE l.project_id = project_id_param
        AND DATE(s.started_at) = date_param
        GROUP BY device_type
    ) sub;
    
    -- Aggregate browsers
    SELECT jsonb_object_agg(browser, count)
    INTO browsers_data
    FROM (
        SELECT browser, COUNT(*) as count
        FROM sessions s
        JOIN links l ON s.link_id = l.id
        WHERE l.project_id = project_id_param
        AND DATE(s.started_at) = date_param
        GROUP BY browser
    ) sub;
    
    -- Aggregate countries
    SELECT jsonb_object_agg(country, count)
    INTO countries_data
    FROM (
        SELECT country, COUNT(*) as count
        FROM sessions s
        JOIN links l ON s.link_id = l.id
        WHERE l.project_id = project_id_param
        AND DATE(s.started_at) = date_param
        AND country IS NOT NULL
        GROUP BY country
    ) sub;
    
    -- Insert or update aggregation
    INSERT INTO analytics_daily (
        project_id,
        date,
        total_views,
        unique_viewers,
        total_duration,
        completed_views,
        avg_watch_time,
        completion_rate,
        devices,
        browsers,
        countries
    ) VALUES (
        project_id_param,
        date_param,
        total_views_count,
        unique_viewers_count,
        total_duration_sum,
        completed_views_count,
        avg_watch_time_calc,
        completion_rate_calc,
        devices_data,
        browsers_data,
        countries_data
    )
    ON CONFLICT (project_id, date)
    DO UPDATE SET
        total_views = EXCLUDED.total_views,
        unique_viewers = EXCLUDED.unique_viewers,
        total_duration = EXCLUDED.total_duration,
        completed_views = EXCLUDED.completed_views,
        avg_watch_time = EXCLUDED.avg_watch_time,
        completion_rate = EXCLUDED.completion_rate,
        devices = EXCLUDED.devices,
        browsers = EXCLUDED.browsers,
        countries = EXCLUDED.countries,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- ==================== VIEWS ====================

-- Active projects with statistics
CREATE VIEW active_projects_stats AS
SELECT
    p.*,
    COUNT(DISTINCT i.id) as images_count,
    COUNT(DISTINCT v.id) as videos_count,
    COUNT(DISTINCT m.id) as markers_count,
    COUNT(DISTINCT l.id) as links_count,
    u.email as owner_email,
    u.name as owner_name
FROM projects p
LEFT JOIN images i ON i.project_id = p.id
LEFT JOIN videos v ON v.project_id = p.id
LEFT JOIN markers m ON m.image_id = i.id
LEFT JOIN links l ON l.project_id = p.id
LEFT JOIN users u ON u.id = p.user_id
WHERE p.status = 'active' AND p.deleted_at IS NULL
GROUP BY p.id, u.email, u.name;

-- User statistics view
CREATE VIEW user_statistics AS
SELECT
    u.id,
    u.email,
    u.name,
    COUNT(DISTINCT p.id) as total_projects,
    SUM(p.total_views) as total_views,
    uq.current_storage_bytes,
    uq.max_storage_bytes,
    ROUND((uq.current_storage_bytes::DECIMAL / uq.max_storage_bytes * 100), 2) as storage_usage_percent
FROM users u
LEFT JOIN projects p ON p.user_id = u.id AND p.status = 'active'
LEFT JOIN user_quotas uq ON uq.user_id = u.id
GROUP BY u.id, u.email, u.name, uq.current_storage_bytes, uq.max_storage_bytes;

-- ==================== SAMPLE DATA (for development) ====================

-- Insert admin user (password: Admin123!)
-- Note: In production, hash the password properly
INSERT INTO users (email, password_hash, name, role, email_verified)
VALUES (
    'admin@argument.io',
    '$2b$10$YourHashedPasswordHere',
    'Admin User',
    'admin',
    true
);

-- ==================== COMMENTS ====================

COMMENT ON TABLE users IS 'User accounts and authentication data';
COMMENT ON TABLE user_quotas IS 'Storage and usage quotas per user';
COMMENT ON TABLE projects IS 'AR projects containing images, videos and markers';
COMMENT ON TABLE images IS 'Uploaded images used as AR markers';
COMMENT ON TABLE videos IS 'Videos to be overlaid on markers';
COMMENT ON TABLE markers IS 'Generated AR markers with tracking data';
COMMENT ON TABLE links IS 'Public WebAR viewer links';
COMMENT ON TABLE sessions IS 'AR viewing sessions for analytics';
COMMENT ON TABLE analytics_events IS 'Individual events during AR sessions';
COMMENT ON TABLE analytics_daily IS 'Pre-aggregated daily analytics for performance';
COMMENT ON TABLE audit_logs IS 'Audit trail for administrative actions';

-- ==================== CLEANUP POLICIES ====================

-- Automatically delete old refresh tokens
CREATE OR REPLACE FUNCTION delete_expired_refresh_tokens()
RETURNS void AS $$
BEGIN
    DELETE FROM refresh_tokens
    WHERE expires_at < CURRENT_TIMESTAMP - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Automatically soft-delete old projects marked for deletion
CREATE OR REPLACE FUNCTION cleanup_deleted_projects()
RETURNS void AS $$
BEGIN
    DELETE FROM projects
    WHERE deleted_at IS NOT NULL
    AND deleted_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Note: Schedule these functions to run periodically using pg_cron or external scheduler
