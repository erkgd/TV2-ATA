import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../environments/environment';
import { AuthResponse, User } from '../models';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = `${environment.apiUrl}/users`;
  private tokenKey = 'auth_token';

  constructor(private http: HttpClient) { }
  register(username: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/register/`, { username, password })
      .pipe(
        tap(response => {
          if (response && response.token) {
            this.saveToken(response.token);
          }
        })
      );
  }
  login(username: string, password: string): Observable<AuthResponse> {
    // Support both endpoints
    return this.http.post<AuthResponse>(`${this.apiUrl}/login/`, { username, password })
      .pipe(
        tap(response => {
          if (response && response.token) {
            this.saveToken(response.token);
          }
        })
      );
  }
  
  // For compatibility with clients using the api-token-auth endpoint
  tokenAuth(username: string, password: string): Observable<AuthResponse> {
    return this.login(username, password);
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
  }
  getProfile(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/profile/`);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  saveToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }
  getCurrentUser(): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/me/`);
  }
  
  isAuthenticated(): boolean {
    return this.isLoggedIn();
  }
}
