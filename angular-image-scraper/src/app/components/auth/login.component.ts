import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  loading = false;
  submitted = false;
  error: string | null = null;
  returnUrl: string = '/';
  
  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService
  ) {
    this.loginForm = this.fb.group({
      username: ['', [Validators.required]],
      password: ['', [Validators.required]]
    });
    
    // Redirect if already logged in
    if (this.authService.isLoggedIn()) {
      this.router.navigate(['/']);
    }
  }

  ngOnInit(): void {
    // Get return URL from route parameters or default to '/'
    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/';
  }

  onSubmit(): void {
    this.submitted = true;
    
    if (this.loginForm.invalid) {
      return;
    }
    
    this.loading = true;
    this.error = null;
    
    const { username, password } = this.loginForm.value;
    
    this.authService.login(username, password).subscribe({      next: (response) => {
        this.authService.saveToken(response.token);
        this.router.navigate([this.returnUrl]);
      },
      error: (err) => {
        console.error('Login error:', err);
        if (err?.error?.detail) {
          this.error = err.error.detail;
          if (err?.error?.username_exists) {
            this.error += ' (Username exists but password is incorrect)';
          }
        } else {
          this.error = 'Login failed. Please check your credentials.';
        }
        this.loading = false;
      }
    });
  }
}
