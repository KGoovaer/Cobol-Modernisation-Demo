import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { Router } from '@angular/router';

/**
 * T006 / T021 – Base API service wrapping HttpClient.
 * All requests use `withCredentials: true` so session cookies are sent.
 * On 401 response the 401 interceptor (below) redirects to /login.
 */
@Injectable({ providedIn: 'root' })
export class ApiService {
  protected readonly http = inject(HttpClient);
  private readonly router = inject(Router);

  get<T>(path: string, params?: Record<string, string | number | boolean>): Observable<T> {
    let httpParams = new HttpParams();
    if (params) {
      Object.entries(params).forEach(([k, v]) => {
        if (v !== null && v !== undefined) {
          httpParams = httpParams.set(k, String(v));
        }
      });
    }
    return this.http.get<T>(path, { withCredentials: true, params: httpParams });
  }

  post<T>(path: string, body: unknown, options?: { formEncoded?: boolean }): Observable<T> {
    if (options?.formEncoded) {
      const params = new URLSearchParams();
      Object.entries(body as Record<string, string>).forEach(([k, v]) => params.set(k, v));
      return this.http.post<T>(path, params.toString(), {
        withCredentials: true,
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      });
    }
    return this.http.post<T>(path, body, { withCredentials: true });
  }

  patch<T>(path: string, body: unknown): Observable<T> {
    return this.http.patch<T>(path, body, { withCredentials: true });
  }

  delete<T>(path: string): Observable<T> {
    return this.http.delete<T>(path, { withCredentials: true });
  }

  getBlob(path: string): Observable<Blob> {
    return this.http.get(path, { withCredentials: true, responseType: 'blob' });
  }

  /** T021: handle 401 — redirect to /login and clear session */
  handle401(): void {
    this.router.navigate(['/login']);
  }
}
