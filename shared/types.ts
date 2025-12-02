export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

export enum ProjectStatus {
  ACTIVE = 'active',
  ARCHIVED = 'archived',
  DELETED = 'deleted',
}

export enum VideoStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

export enum TrackingQuality {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  FAIR = 'fair',
  POOR = 'poor',
}

export enum EventType {
  VIEW_STARTED = 'view_started',
  MARKER_DETECTED = 'marker_detected',
  VIDEO_STARTED = 'video_started',
  VIDEO_PAUSED = 'video_paused',
  VIDEO_COMPLETED = 'video_completed',
  VIDEO_REPLAYED = 'video_replayed',
  SESSION_ENDED = 'session_ended',
}

export interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  role: UserRole;
  isActive: boolean;
  emailVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Project {
  id: string;
  userId: string;
  name: string;
  description?: string;
  tags?: string[];
  isPublic: boolean;
  status: ProjectStatus;
  totalViews: number;
  createdAt: string;
  updatedAt: string;
}

export interface Image {
  id: string;
  projectId: string;
  name: string;
  description?: string;
  filePath: string;
  thumbnailPath?: string;
  originalSize: string;
  width: number;
  height: number;
  format: string;
  mimeType: string;
  trackingScore?: number;
  metadata?: any;
  createdAt: string;
  updatedAt: string;
}

export interface Video {
  id: string;
  projectId: string;
  name: string;
  description?: string;
  filePath: string;
  posterPath?: string;
  originalSize: string;
  processedSize?: string;
  duration?: number;
  width?: number;
  height?: number;
  format: string;
  codec?: string;
  bitrate?: number;
  fps?: number;
  status: VideoStatus;
  autoplay: boolean;
  loop: boolean;
  processingError?: string;
  metadata?: any;
  createdAt: string;
  updatedAt: string;
  processedAt?: string;
}

export interface Marker {
  id: string;
  imageId: string;
  videoId?: string;
  markerData: string;
  markerFilePath?: string;
  trackingQuality?: TrackingQuality;
  settings: any;
  createdAt: string;
  updatedAt: string;
}

export interface Link {
  id: string;
  projectId: string;
  markerId: string;
  url: string;
  isActive: boolean;
  expiresAt?: string;
  maxViews?: number;
  currentViews: number;
  createdAt: string;
  updatedAt: string;
}
