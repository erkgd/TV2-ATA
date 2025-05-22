import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  constructor(private authService: AuthService, private router: Router) {}
  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Get the auth token from the service
    const token = this.authService.getToken();
    
    // Clone the request and set proper headers
    let modifiedRequest = request;
    
    // Set Content-Type for POST/PUT/PATCH requests
    if (['POST', 'PUT', 'PATCH'].includes(request.method)) {
      modifiedRequest = request.clone({
        setHeaders: {
          'Content-Type': 'application/json'
        }
      });
    }
    
    // Add authorization token if exists
    if (token) {
      modifiedRequest = modifiedRequest.clone({
        setHeaders: {
          Authorization: `Token ${token}`
        }
      });
    }    // Send the modified request to the next handler
    return next.handle(modifiedRequest).pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          // Auto logout if 401 response returned from api
          this.authService.logout();
          this.router.navigate(['/login']);
        }
        return throwError(() => error);
      })
    );
  }
}
