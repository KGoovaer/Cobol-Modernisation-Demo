import { HttpInterceptorFn, HttpRequest, HttpHandlerFn } from '@angular/common/http';

/**
 * T005 – Reads the XSRF-TOKEN cookie and attaches its value as the
 * X-XSRF-TOKEN request header for all state-changing HTTP requests.
 *
 * Spring Security reads this header to validate CSRF tokens when using
 * CookieCsrfTokenRepository.withHttpOnlyFalse().
 */
export const httpXsrfInterceptor: HttpInterceptorFn = (
  req: HttpRequest<unknown>,
  next: HttpHandlerFn
) => {
  const mutatingMethods = ['POST', 'PUT', 'PATCH', 'DELETE'];
  if (!mutatingMethods.includes(req.method)) {
    return next(req);
  }

  const token = getCookie('XSRF-TOKEN');
  if (!token) {
    return next(req);
  }

  const cloned = req.clone({
    setHeaders: { 'X-XSRF-TOKEN': token },
  });
  return next(cloned);
};

function getCookie(name: string): string | null {
  const nameEQ = name + '=';
  const cookies = document.cookie.split(';');
  for (const cookie of cookies) {
    const c = cookie.trim();
    if (c.startsWith(nameEQ)) {
      return decodeURIComponent(c.substring(nameEQ.length));
    }
  }
  return null;
}
