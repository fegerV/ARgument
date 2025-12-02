import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Project } from './entities/project.entity';

@Injectable()
export class ProjectsService {
  constructor(
    @InjectRepository(Project)
    private projectsRepository: Repository<Project>,
  ) {}

  async findAll(userId: string): Promise<Project[]> {
    return this.projectsRepository.find({
      where: { userId },
      relations: ['images', 'videos'],
    });
  }

  async findOne(id: string, userId: string): Promise<Project> {
    return this.projectsRepository.findOne({
      where: { id, userId },
      relations: ['images', 'videos', 'links'],
    });
  }

  async create(data: Partial<Project>): Promise<Project> {
    const project = this.projectsRepository.create(data);
    return this.projectsRepository.save(project);
  }

  async update(id: string, userId: string, data: Partial<Project>): Promise<Project> {
    await this.projectsRepository.update({ id, userId }, data);
    return this.findOne(id, userId);
  }

  async remove(id: string, userId: string): Promise<void> {
    await this.projectsRepository.softDelete({ id, userId });
  }
}
