import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Project } from '../../projects/entities/project.entity';
import { Marker } from '../../markers/entities/marker.entity';
import { Session } from '../../analytics/entities/session.entity';

@Entity('links')
export class Link {
  @PrimaryColumn({ length: 50 })
  id: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'marker_id', type: 'uuid' })
  markerId: string;

  @Column({ type: 'text' })
  url: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'password_hash', nullable: true })
  passwordHash?: string;

  @Column({ name: 'expires_at', type: 'timestamp with time zone', nullable: true })
  expiresAt?: Date;

  @Column({ name: 'max_views', nullable: true })
  maxViews?: number;

  @Column({ name: 'current_views', default: 0 })
  currentViews: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;

  @ManyToOne(() => Project, (project) => project.links)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @ManyToOne(() => Marker, (marker) => marker.links)
  @JoinColumn({ name: 'marker_id' })
  marker: Marker;

  @OneToMany(() => Session, (session) => session.link)
  sessions: Session[];
}
