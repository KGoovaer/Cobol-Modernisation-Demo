import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';
import { map } from 'rxjs';

/**
 * T018 – AuthGuard: redirect to /login if not authenticated.
 */
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.currentUser) {
    return true;
  }

  return auth.me().pipe(
    map((user) => {
      if (user) return true;
      return router.createUrlTree(['/login']);
    })
  );
};
