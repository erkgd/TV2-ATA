import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Image, SearchHistory } from '../models';

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  private apiUrl = `${environment.apiUrl}`;

  constructor(private http: HttpClient) { }
  searchImages(
    query: string, 
    copyrightFilter?: string, 
    transparentOnly?: boolean,
    useApi?: boolean,
    maxResults: number = 20
  ): Observable<Image[]> {
    let params = new HttpParams()
      .set('query', query)
      .set('max_results', maxResults.toString());
    
    if (copyrightFilter) {
      params = params.set('copyright_filter', copyrightFilter);
    }
    
    if (transparentOnly !== undefined) {
      params = params.set('transparent_only', transparentOnly.toString());
    }
    
    if (useApi !== undefined) {
      params = params.set('use_api', useApi.toString());
    }
    
    // Use the Django advanced-search endpoint
    return this.http.get<Image[]>(`${this.apiUrl}/advanced-search/`, { params });
  }
    getSearchOptions(): Observable<any> {
    // Use the search options endpoint we created
    return this.http.get<any>(`${this.apiUrl}/search/options/`);
  }

  getSearchHistory(): Observable<SearchHistory[]> {
    return this.http.get<SearchHistory[]>(`${environment.apiUrl}/history/`);
  }
  
  advancedSearch(params: any): Observable<Image[]> {
    return this.http.post<Image[]>(`/advanced-search/`, params);
  }
}

