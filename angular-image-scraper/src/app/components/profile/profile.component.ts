import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { ImageService } from '../../services/image.service';
import { User, Image } from '../../models';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent implements OnInit {
  user: User | null = null;
  userImages: Image[] = [];
  favoriteImages: Image[] = [];
  loading = {
    user: true,
    images: true,
    favorites: true
  };
  error = {
    user: '',
    images: '',
    favorites: ''
  };

  constructor(
    private authService: AuthService,
    private imageService: ImageService
  ) { }

  ngOnInit(): void {
    this.loadUserProfile();
    // Load favorite images from profile endpoint
    this.loadFavoriteImages();
  }
  loadUserProfile(): void {
    this.loading.user = true;
    this.authService.getCurrentUser().subscribe({
      next: (user: User) => {
        this.user = user;
        this.loading.user = false;
      },
      error: (err: any) => {
        console.error('Error loading profile:', err);
        this.error.user = 'Failed to load profile information. Please try again.';
        this.loading.user = false;
      }
    });
  }


  loadFavoriteImages(): void {
    this.loading.favorites = true;
    this.imageService.getUserFavorites().subscribe({
      next: (favorites: Image[]) => {
        this.favoriteImages = favorites;
        this.loading.favorites = false;
      },
      error: (err) => {
        console.error('Error loading favorites:', err);
        this.error.favorites = 'Failed to load your favorite images. Please try again.';
        this.loading.favorites = false;
      }
    });
  }

  deleteImage(imageId: string): void {
    if (confirm('Are you sure you want to delete this image?')) {
      this.imageService.deleteImage(imageId).subscribe({
        next: () => {
          this.userImages = this.userImages.filter(img => this.getImageId(img) !== imageId);
        },
        error: (err) => {
          console.error('Error deleting image:', err);
          alert('Failed to delete image. Please try again.');
        }
      });
    }
  }

  removeFromFavorites(imageId: string): void {
    this.imageService.unlikeImage(imageId).subscribe({
      next: () => {
        this.favoriteImages = this.favoriteImages.filter(img => this.getImageId(img) !== imageId);
      },
      error: (err) => {
        console.error('Error removing from favorites:', err);
        alert('Failed to remove from favorites. Please try again.');
      }
    });
  }

  // Helper method to get image ID regardless of property name
  getImageId(image: Image): string {
    return image.id || image._id || '';
  }
}
