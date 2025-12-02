import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Project } from '../../projects/entities/project.entity';
import { Marker } from '../../markers/entities/marker.entity';

@Entity('images')
export class Image {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ name: 'file_path', type: 'text' })
  filePath: string;

  @Column({ name: 'thumbnail_path', type: 'text', nullable: true })
  thumbnailPath?: string;

  @Column({ name: 'original_size', type: 'bigint' })
  originalSize: string;

  @Column()
  width: number;

  @Column()
  height: number;

  @Column({ length: 10 })
  format: string;

  @Column({ name: 'mime_type', length: 50 })
  mimeType: string;

  @Column({ name: 'tracking_score', type: 'decimal', precision: 5, scale: 2, nullable: true })
  trackingScore?: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: any;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;

  @ManyToOne(() => Project, (project) => project.images)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @OneToMany(() => Marker, (marker) => marker.image)
  markers: Marker[];
}
