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
import { Image } from '../../images/entities/image.entity';
import { Video } from '../../videos/entities/video.entity';
import { Link } from '../../links/entities/link.entity';

export enum TrackingQuality {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  FAIR = 'fair',
  POOR = 'poor',
}

@Entity('markers')
export class Marker {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'image_id', type: 'uuid' })
  imageId: string;

  @Column({ name: 'video_id', type: 'uuid', nullable: true })
  videoId?: string;

  @Column({ name: 'marker_data', type: 'text' })
  markerData: string;

  @Column({ name: 'marker_file_path', type: 'text', nullable: true })
  markerFilePath?: string;

  @Column({
    name: 'tracking_quality',
    type: 'enum',
    enum: TrackingQuality,
    nullable: true,
  })
  trackingQuality?: TrackingQuality;

  @Column({ type: 'jsonb', default: {} })
  settings: any;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;

  @ManyToOne(() => Image, (image) => image.markers)
  @JoinColumn({ name: 'image_id' })
  image: Image;

  @ManyToOne(() => Video, (video) => video.markers, { nullable: true })
  @JoinColumn({ name: 'video_id' })
  video?: Video;

  @OneToMany(() => Link, (link) => link.marker)
  links: Link[];
}
