import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Link } from '../../links/entities/link.entity';
import { AnalyticsEvent } from './analytics-event.entity';

@Entity('sessions')
export class Session {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'link_id', length: 50 })
  linkId: string;

  @Column({ nullable: true })
  fingerprint?: string;

  @Column({ name: 'ip_address', type: 'inet', nullable: true })
  ipAddress?: string;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent?: string;

  @Column({ name: 'device_type', length: 50, nullable: true })
  deviceType?: string;

  @Column({ length: 100, nullable: true })
  browser?: string;

  @Column({ length: 100, nullable: true })
  os?: string;

  @Column({ length: 2, nullable: true })
  country?: string;

  @Column({ nullable: true })
  city?: string;

  @CreateDateColumn({ name: 'started_at', type: 'timestamp with time zone' })
  startedAt: Date;

  @Column({ name: 'ended_at', type: 'timestamp with time zone', nullable: true })
  endedAt?: Date;

  @Column({ nullable: true })
  duration?: number;

  @Column({ name: 'marker_detected_at', type: 'timestamp with time zone', nullable: true })
  markerDetectedAt?: Date;

  @Column({ name: 'video_started_at', type: 'timestamp with time zone', nullable: true })
  videoStartedAt?: Date;

  @Column({ name: 'video_completed', default: false })
  videoCompleted: boolean;

  @ManyToOne(() => Link, (link) => link.sessions)
  @JoinColumn({ name: 'link_id' })
  link: Link;

  @OneToMany(() => AnalyticsEvent, (event) => event.session)
  events: AnalyticsEvent[];
}
