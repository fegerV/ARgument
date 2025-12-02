import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('user_quotas')
export class UserQuota {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'max_projects', default: 5 })
  maxProjects: number;

  @Column({ name: 'max_storage_bytes', type: 'bigint', default: 524288000 })
  maxStorageBytes: string;

  @Column({ name: 'max_video_length_seconds', default: 120 })
  maxVideoLengthSeconds: number;

  @Column({ name: 'max_views_per_month', default: 1000 })
  maxViewsPerMonth: number;

  @Column({ name: 'current_storage_bytes', type: 'bigint', default: 0 })
  currentStorageBytes: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;

  @OneToOne(() => User, (user) => user.quota)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
