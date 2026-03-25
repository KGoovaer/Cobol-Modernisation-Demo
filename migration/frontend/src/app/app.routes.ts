import { Routes } from '@angular/router';
import { authGuard } from './auth/auth.guard';
import { roleGuard } from './auth/role.guard';

/**
 * T007 – Lazy-loaded route stubs for /payment, /lists, and /admin modules.
 */
export const appRoutes: Routes = [
  { path: '', redirectTo: '/payment', pathMatch: 'full' },
  {
    path: 'login',
    loadComponent: () =>
      import('./auth/login/login.component').then((m) => m.LoginComponent),
  },
  {
    path: '',
    loadComponent: () =>
      import('./core/shell/shell.component').then((m) => m.ShellComponent),
    canActivate: [authGuard],
    children: [
      {
        path: 'payment',
        canActivate: [roleGuard],
        data: { allowedRoles: ['SUBMITTER'] },
        loadComponent: () =>
          import('./payment/payment-form/payment-form.component').then(
            (m) => m.PaymentFormComponent
          ),
      },
      {
        path: 'lists',
        canActivate: [roleGuard],
        data: { allowedRoles: ['SUBMITTER', 'READ_ONLY'] },
        children: [
          { path: '', redirectTo: 'payments', pathMatch: 'full' },
          {
            path: 'payments',
            loadComponent: () =>
              import('./lists/payment-list/payment-list.component').then(
                (m) => m.PaymentListComponent
              ),
          },
          {
            path: 'rejections',
            loadComponent: () =>
              import('./lists/rejection-list/rejection-list.component').then(
                (m) => m.RejectionListComponent
              ),
          },
          {
            path: 'discrepancies',
            loadComponent: () =>
              import('./lists/discrepancy-list/discrepancy-list.component').then(
                (m) => m.DiscrepancyListComponent
              ),
          },
        ],
      },
      {
        path: 'admin',
        canActivate: [roleGuard],
        data: { allowedRoles: ['ADMIN'] },
        loadComponent: () =>
          import('./admin/user-management/user-management.component').then(
            (m) => m.UserManagementComponent
          ),
      },
      {
        path: 'forbidden',
        loadComponent: () =>
          import('./core/forbidden/forbidden.component').then(
            (m) => m.ForbiddenComponent
          ),
      },
    ],
  },
  { path: '**', redirectTo: '/payment' },
];
