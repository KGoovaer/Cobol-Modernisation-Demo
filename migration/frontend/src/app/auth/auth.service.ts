import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, tap, catchError, of } from 'rxjs';
import { Router } from '@angular/router';
import { ApiService } from '../core/api.service';

export interface UserDto {
  id: string;
  username: string;
  role: 'SUBMITTER' | 'READ_ONLY' | 'ADMIN';
  active: boolean;
  mutualityCodes: number[];
  createdAt: string;
}

/**
 * T017 – Authentication service managing current user state.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(ApiService);
  private readonly router = inject(Router);

  readonly currentUser$ = new BehaviorSubject<UserDto | null>(null);

  get currentUser(): UserDto | null {
    return this.currentUser$.value;
  }

  /** Called on app init to restore session. */
  me() {
    return this.api.get<UserDto>('/api/auth/me').pipe(
      tap((user) => this.currentUser$.next(user)),
      catchError(() => {
        this.currentUser$.next(null);
        return of(null);
      })
    );
  }

  login(username: string, password: string) {
    return this.api.post<UserDto>('/api/auth/login', { username, password }, { formEncoded: true }).pipe(
      tap((user) => this.currentUser$.next(user))
    );
  }

  logout() {
    return this.api.post<void>('/api/auth/logout', {}).pipe(
      tap(() => {
        this.currentUser$.next(null);
        this.router.navigate(['/login']);
      }),
      catchError(() => {
        this.currentUser$.next(null);
        this.router.navigate(['/login']);
        return of(null);
      })
    );
  }

  hasRole(role: UserDto['role']): boolean {
    return this.currentUser?.role === role;
  }

  hasAnyRole(...roles: UserDto['role'][]): boolean {
    return roles.includes(this.currentUser?.role as UserDto['role']);
  }
}
