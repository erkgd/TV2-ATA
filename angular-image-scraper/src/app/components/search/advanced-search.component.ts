import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { SearchService } from '../../services/search.service';
import { Image } from '../../models';

@Component({
  selector: 'app-advanced-search',
  templateUrl: './advanced-search.component.html',
  styleUrls: ['./advanced-search.component.scss']
})
export class AdvancedSearchComponent implements OnInit {
  searchForm: FormGroup;
  results: Image[] = [];
  loading = false;
  error = '';
  searched = false;
  
  constructor(
    private fb: FormBuilder,
    private searchService: SearchService
  ) {
    this.searchForm = this.fb.group({
      query: [''],
      size: ['any'],
      type: ['any'],
      color: ['any'],
      aspect: ['any'],
      license: ['any'],
      site: [''],
      excludeTerms: [''],
      safeSearch: [true],
      dateRange: ['any']
    });
  }

  ngOnInit(): void {
  }

  onSubmit(): void {
    if (this.searchForm.value.query.trim() === '') {
      this.error = 'Please enter search terms';
      return;
    }
    
    this.loading = true;
    this.error = '';
    this.searched = true;
      const params = this.prepareSearchParams();
    
    this.searchService.advancedSearch(params).subscribe({
      next: (results: Image[]) => {
        this.results = results;
        this.loading = false;
      },
      error: (err: any) => {
        console.error('Search error:', err);
        this.error = 'An error occurred during search. Please try again.';
        this.loading = false;
      }
    });
  }

  private prepareSearchParams(): any {
    const formValue = this.searchForm.value;
    const params: any = {
      query: formValue.query
    };
    
    // Only add non-default parameters
    if (formValue.size !== 'any') params.size = formValue.size;
    if (formValue.type !== 'any') params.type = formValue.type;
    if (formValue.color !== 'any') params.color = formValue.color;
    if (formValue.aspect !== 'any') params.aspect = formValue.aspect;
    if (formValue.license !== 'any') params.license = formValue.license;
    if (formValue.site) params.site = formValue.site;
    if (formValue.excludeTerms) params.excludeTerms = formValue.excludeTerms;
    if (!formValue.safeSearch) params.safeSearch = false;
    if (formValue.dateRange !== 'any') params.dateRange = formValue.dateRange;
    
    return params;
  }
}
