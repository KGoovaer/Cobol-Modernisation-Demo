import { HttpInterceptorFn, HttpRequest, HttpHandlerFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

/**
 * T021 – HTTP 401 interceptor: on any 401 response, redirect to /login.
 */
export const authInterceptor: HttpInterceptorFn = (
  req: HttpRequest<unknown>,
  next: HttpHandlerFn
) => {
  const router = inject(Router);
  return next(req).pipe(
    catchError((error) => {
      if (error?.status === 401 && !req.url.includes('/api/auth/login')) {
        router.navigate(['/login']);
      }
      return throwError(() => error);
    })
  );
};
