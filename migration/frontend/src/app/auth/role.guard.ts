import { inject } from '@angular/core';
import { CanActivateFn, ActivatedRouteSnapshot, Router } from '@angular/router';
import { AuthService } from './auth.service';

/**
 * T018 – RoleGuard: return 403 view if role not in allowedRoles route data.
 */
export const roleGuard: CanActivateFn = (route: ActivatedRouteSnapshot) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const allowedRoles: string[] = route.data['allowedRoles'] ?? [];

  if (auth.currentUser && allowedRoles.includes(auth.currentUser.role)) {
    return true;
  }

  return router.createUrlTree(['/forbidden']);
};
