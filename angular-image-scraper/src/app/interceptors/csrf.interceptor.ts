import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpXsrfTokenExtractor
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class CsrfInterceptor implements HttpInterceptor {

  constructor(private tokenExtractor: HttpXsrfTokenExtractor) {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Django uses 'csrftoken' as the cookie name
    const csrfToken = this.tokenExtractor.getToken() as string;
    
    if (csrfToken !== null && !request.headers.has('X-CSRFToken')) {
      request = request.clone({
        headers: request.headers.set('X-CSRFToken', csrfToken)
      });
    }
    
    return next.handle(request);
  }
}
