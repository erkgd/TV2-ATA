import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Image, Comment } from '../../models';
import { ImageService } from '../../services/image.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-image-detail',
  templateUrl: './image-detail.component.html',
  styleUrls: ['./image-detail.component.scss']
})
export class ImageDetailComponent implements OnInit {
  imageId: string | null = null;
  image: Image | null = null;
  similarImages: Image[] = [];
  comments: Comment[] = [];
  userLiked = false;
  isLoggedIn = false;
  loading = true;
  error: string | null = null;
  
  commentForm: FormGroup;
  submittingComment = false;
  
  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private fb: FormBuilder,
    private imageService: ImageService,
    private authService: AuthService
  ) {
    this.commentForm = this.fb.group({
      text: ['', [Validators.required, Validators.minLength(2)]]
    });
  }

  ngOnInit(): void {
    this.isLoggedIn = this.authService.isLoggedIn();
    this.route.paramMap.subscribe(params => {
      this.imageId = params.get('id');
      if (this.imageId) {
        // Si el ID parece ser un MongoDB ID (cadena), lo convertimos a número para Django
        if (this.isMongoId(this.imageId)) {
          console.warn('MongoDB ID detectado, intente usar la API de Django con este ID:', this.imageId);
        }
        this.loadImage();
      } else {
        this.error = 'Image ID not provided';
        this.loading = false;
      }
    });
  }
  
  // Helper method para detectar si es un MongoDB ID
  private isMongoId(id: string): boolean {
    return /^[0-9a-fA-F]{24}$/.test(id);
  }

  loadImage(): void {
    if (!this.imageId) return;
    
    if (!this.imageId || this.imageId === 'undefined') {
      this.error = 'Invalid image ID';
      this.loading = false;
      return;
    }
    this.loading = true;
    this.imageService.getImageById(this.imageId).subscribe({
      next: (data) => {
        this.image = data;
        this.userLiked = data.userLiked || false;
        this.comments = data.comments || [];
        this.similarImages = data.similarImages || [];
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading image', err);
        this.error = 'Failed to load image details. Please try again.';
        this.loading = false;
      }
    });
  }

  toggleLike(): void {
    if (!this.isLoggedIn) {
      this.router.navigate(['/login'], { queryParams: { returnUrl: this.router.url } });
      return;
    }

    if (!this.imageId) return;
    
    this.imageService.likeImage(this.imageId).subscribe({
      next: (response) => {
        this.userLiked = response.liked;
        
        // Update likes count
        if (this.image) {
          if (response.liked) {
            this.image.likesCount = (this.image.likesCount || 0) + 1;
          } else {
            this.image.likesCount = Math.max(0, (this.image.likesCount || 0) - 1);
          }
        }
      },
      error: (err) => {
        console.error('Error toggling like', err);
      }
    });
  }

  submitComment(): void {
    if (!this.isLoggedIn) {
      this.router.navigate(['/login'], { queryParams: { returnUrl: this.router.url } });
      return;
    }

    if (!this.imageId || this.commentForm.invalid) return;
    
    const text = this.commentForm.get('text')?.value;
    this.submittingComment = true;
    
    this.imageService.addComment(this.imageId, text).subscribe({
      next: (comment) => {
        this.comments.unshift(comment);
        this.commentForm.reset();
        this.submittingComment = false;
        
        // Update comments count
        if (this.image) {
          this.image.commentsCount = (this.image.commentsCount || 0) + 1;
        }
      },
      error: (err) => {
        console.error('Error adding comment', err);
        this.submittingComment = false;
      }
    });
  }

  goBack(): void {
    window.history.back();
  }
}
