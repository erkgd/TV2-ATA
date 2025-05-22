import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent {
  registerForm: FormGroup;
  loading = false;
  submitted = false;
  error: string | null = null;
  
  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService
  ) {
    this.registerForm = this.fb.group({
      username: ['', [Validators.required, Validators.minLength(3)]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, {
      validator: this.passwordMatchValidator
    });
    
    // Redirect if already logged in
    if (this.authService.isLoggedIn()) {
      this.router.navigate(['/']);
    }
  }

  // Custom validator for password matching
  passwordMatchValidator(formGroup: FormGroup) {
    const password = formGroup.get('password')?.value;
    const confirmPassword = formGroup.get('confirmPassword')?.value;
    
    if (password !== confirmPassword) {
      formGroup.get('confirmPassword')?.setErrors({ mismatch: true });
    } else {
      formGroup.get('confirmPassword')?.setErrors(null);
    }
  }

  onSubmit(): void {
    this.submitted = true;
    
    if (this.registerForm.invalid) {
      return;
    }
    
    this.loading = true;
    this.error = null;
    
    const { username, password } = this.registerForm.value;
    
    this.authService.register(username, password).subscribe({
      next: (response) => {
        // Automatically login after registration
        this.authService.login(username, password).subscribe({
          next: (loginResponse) => {
            this.authService.saveToken(loginResponse.token);
            this.router.navigate(['/']);
          },
          error: (err) => {
            // Registration successful but login failed
            this.router.navigate(['/login'], { 
              queryParams: { registrationSuccess: 'true' } 
            });
          }
        });
      },
      error: (err) => {
        console.error('Registration error:', err);
        if (err?.error?.detail) {
          this.error = err.error.detail;
        } else {
          this.error = 'Registration failed. Please try again.';
        }
        this.loading = false;
      }
    });
  }
}
