export const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
export const MAX_VIDEO_SIZE = 100 * 1024 * 1024; // 100MB
export const MAX_VIDEO_DURATION = 120; // 2 minutes

export const ALLOWED_IMAGE_FORMATS = ['image/jpeg', 'image/png'];
export const ALLOWED_VIDEO_FORMATS = ['video/mp4', 'video/webm', 'video/quicktime'];

export const MIN_IMAGE_WIDTH = 640;
export const MIN_IMAGE_HEIGHT = 480;

export const DEFAULT_PROJECT_QUOTA = {
  maxProjects: 5,
  maxStorageBytes: 524288000, // 500MB
  maxVideoLengthSeconds: 120,
  maxViewsPerMonth: 1000,
};
