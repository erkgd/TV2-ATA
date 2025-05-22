import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  isLoggedIn: boolean = false;
  username: string | null = null;

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }
  ngOnInit(): void {
    this.isLoggedIn = this.authService.isLoggedIn();
    
    if (this.isLoggedIn) {
      this.authService.getProfile().subscribe(user => {
        this.username = user?.username || null;
      });
    }
  }

  logout(): void {
    this.authService.logout();
    this.isLoggedIn = false;
    this.username = null;
    this.router.navigate(['/']);
  }
}
