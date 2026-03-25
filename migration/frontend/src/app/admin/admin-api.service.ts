import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../core/api.service';
import { CreateUserRequest, UserAdminDto } from '../core/models';

@Injectable({ providedIn: 'root' })
export class AdminApiService {
  private readonly api = inject(ApiService);

  listUsers(): Observable<UserAdminDto[]> {
    return this.api.get<UserAdminDto[]>('/api/admin/users');
  }

  createUser(req: CreateUserRequest): Observable<UserAdminDto> {
    return this.api.post<UserAdminDto>('/api/admin/users', req);
  }

  deactivateUser(id: string): Observable<UserAdminDto> {
    return this.api.patch<UserAdminDto>(`/api/admin/users/${id}/deactivate`, {});
  }

  resetPassword(id: string, newPassword: string): Observable<void> {
    return this.api.post<void>(`/api/admin/users/${id}/reset-password`, { newPassword });
  }
}
