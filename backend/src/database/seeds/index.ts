import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';

dotenv.config();

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'argument',
  password: process.env.DB_PASSWORD || 'argument',
  database: process.env.DB_DATABASE || 'argument',
});

async function seed() {
  try {
    await dataSource.initialize();
    console.log('✅ Database connection established');

    const passwordHash = await bcrypt.hash('admin123', 12);

    await dataSource.query(`
      INSERT INTO users (id, email, password_hash, name, role, email_verified, is_active)
      VALUES (
        uuid_generate_v4(),
        'admin@argument.io',
        $1,
        'Admin User',
        'admin',
        true,
        true
      )
      ON CONFLICT (email) DO NOTHING;
    `, [passwordHash]);

    console.log('✅ Admin user created: admin@argument.io / admin123');

    const userPasswordHash = await bcrypt.hash('password123', 12);

    await dataSource.query(`
      INSERT INTO users (id, email, password_hash, name, role, email_verified, is_active)
      VALUES (
        uuid_generate_v4(),
        'user@example.com',
        $1,
        'Test User',
        'user',
        true,
        true
      )
      ON CONFLICT (email) DO NOTHING;
    `, [userPasswordHash]);

    console.log('✅ Test user created: user@example.com / password123');

    console.log('🌱 Seed completed successfully');
    
    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
}

seed();
