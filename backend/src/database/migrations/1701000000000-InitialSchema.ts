import { MigrationInterface, QueryRunner } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

export class InitialSchema1701000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    const sqlPath = path.join(__dirname, '../../../../DATABASE_SCHEMA.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    await queryRunner.query(sql);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const tables = [
      'analytics_events',
      'analytics_daily',
      'sessions',
      'links',
      'markers',
      'videos',
      'images',
      'projects',
      'refresh_tokens',
      'user_quotas',
      'users',
      'audit_logs',
    ];

    for (const table of tables) {
      await queryRunner.query(`DROP TABLE IF EXISTS ${table} CASCADE`);
    }

    await queryRunner.query(`DROP TYPE IF EXISTS event_type CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS tracking_quality CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS video_status CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS project_status CASCADE`);
    await queryRunner.query(`DROP TYPE IF EXISTS user_role CASCADE`);

    await queryRunner.query(`DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE`);
    await queryRunner.query(`DROP EXTENSION IF EXISTS "pg_trgm" CASCADE`);
  }
}
