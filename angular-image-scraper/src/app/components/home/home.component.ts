import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { Image } from '../../models';
import { ImageService } from '../../services/image.service';
import { Router, ActivatedRoute } from '@angular/router';
import { SearchService } from '../../services/search.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  searchForm: FormGroup;
  images: Image[] = [];
  trendingImages: Image[] = [];
  // Pagination for trending images
  currentPage: number = 1;
  totalPages: number = 1;
  limit: number = 8;
  searchPerformed = false;
  loading = false;
  error: string | null = null;

  copyrightOptions: any[] = [];
  
  constructor(
    private fb: FormBuilder,
    private imageService: ImageService,
    private searchService: SearchService,
    private router: Router,
    private route: ActivatedRoute
  ) {
    this.searchForm = this.fb.group({
      query: [''],
      copyright_filter: [''],
      transparent_only: [false]
    });
  }

  ngOnInit(): void {
    this.loadSearchOptions();
    // Restore query-based search on reload
    this.route.queryParams.subscribe(params => {
      const q = params['query'];
      if (q) {
        // populate form and execute search
        this.searchForm.patchValue({
          query: q,
          copyright_filter: params['copyright_filter'] || '',
          transparent_only: params['transparent_only'] === 'true'
        });
        this.onSubmit();
      } else {
        // no search params, show trending
        this.searchPerformed = false;
        this.loadTrendingImages(this.currentPage);
      }
    });
  }

  loadTrendingImages(page: number = 1): void {
    this.loading = true;
    this.currentPage = page;
    this.imageService.getAllImages(page, this.limit)
      .subscribe({
        next: (response) => {
          this.trendingImages = response.items;
          // Update pagination
          this.currentPage = response.pagination.page;
          this.totalPages = response.pagination.pages;
          this.loading = false;
        },
        error: (err) => {
          console.error('Error loading trending images', err);
          this.error = 'Failed to load trending images. Please try again.';
          this.loading = false;
        }
      });
  }
  
  /** Change page for trending images */
  changePage(page: number): void {
    if (page < 1 || page > this.totalPages) return;
    this.loadTrendingImages(page);
  }

  loadSearchOptions(): void {
    this.searchService.getSearchOptions()
      .subscribe({
        next: (options) => {
          // Backend returns categories array
          this.copyrightOptions = (options.categories || []).map((c: string) => ({ value: c, label: c }));
        },
        error: (err) => {
          console.error('Error loading search options', err);
        }
      });
  }

  onSubmit(): void {
    if (this.searchForm.valid) {
      const { query, copyright_filter, transparent_only } = this.searchForm.value;
      
      if (!query.trim()) {
        return;
      }

      this.loading = true;
      this.searchPerformed = true;
      
      this.router.navigate([], { queryParams: { query, copyright_filter, transparent_only } });
      this.searchService.searchImages(
        query,
        copyright_filter,
        transparent_only
      ).subscribe({
        next: (images) => {
          this.images = images;
          this.loading = false;
        },
        error: (err) => {
          console.error('Error searching images', err);
          this.error = 'Failed to search images. Please try again.';
          this.loading = false;
        }
      });
    }
  }
}
