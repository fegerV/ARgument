import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Session } from './session.entity';

export enum EventType {
  VIEW_STARTED = 'view_started',
  MARKER_DETECTED = 'marker_detected',
  VIDEO_STARTED = 'video_started',
  VIDEO_PAUSED = 'video_paused',
  VIDEO_COMPLETED = 'video_completed',
  VIDEO_REPLAYED = 'video_replayed',
  SESSION_ENDED = 'session_ended',
}

@Entity('analytics_events')
export class AnalyticsEvent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'session_id', type: 'uuid' })
  sessionId: string;

  @Column({
    name: 'event_type',
    type: 'enum',
    enum: EventType,
  })
  eventType: EventType;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: any;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  timestamp: Date;

  @ManyToOne(() => Session, (session) => session.events)
  @JoinColumn({ name: 'session_id' })
  session: Session;
}
