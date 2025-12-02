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

export enum VideoStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('videos')
export class Video {
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

  @Column({ name: 'poster_path', type: 'text', nullable: true })
  posterPath?: string;

  @Column({ name: 'original_size', type: 'bigint' })
  originalSize: string;

  @Column({ name: 'processed_size', type: 'bigint', nullable: true })
  processedSize?: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  duration?: number;

  @Column({ nullable: true })
  width?: number;

  @Column({ nullable: true })
  height?: number;

  @Column({ length: 10 })
  format: string;

  @Column({ length: 50, nullable: true })
  codec?: string;

  @Column({ nullable: true })
  bitrate?: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  fps?: number;

  @Column({
    type: 'enum',
    enum: VideoStatus,
    default: VideoStatus.PENDING,
  })
  status: VideoStatus;

  @Column({ default: true })
  autoplay: boolean;

  @Column({ default: false })
  loop: boolean;

  @Column({ name: 'processing_error', type: 'text', nullable: true })
  processingError?: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: any;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;

  @Column({ name: 'processed_at', type: 'timestamp with time zone', nullable: true })
  processedAt?: Date;

  @ManyToOne(() => Project, (project) => project.videos)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @OneToMany(() => Marker, (marker) => marker.video)
  markers: Marker[];
}
